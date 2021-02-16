defmodule Soundboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec
  use DynamicSupervisor

  def start(_type, _args) do
    children = if Mix.env == :test do
      [
        # Starts a worker by calling: Soundboard.Worker.start_link(arg)
        # {Soundboard.Worker, arg},
        # Start the Ecto repository
        Soundboard.Repo,
        # Start the endpoint when the application starts
        SoundboardWeb.Endpoint,
        KV.Bucket
      ]
    else
      [
        # Starts a worker by calling: Soundboard.Worker.start_link(arg)
        # {Soundboard.Worker, arg},
        # Start the Ecto repository
        Soundboard.Repo,
        # Start the endpoint when the application starts
        SoundboardWeb.Endpoint,
        KV.Bucket,
        SoundboardWeb.DiscordBot,
        SoundboardWeb.TwitchPubSub,
        SoundboardWeb.SpecialEventHandler,
        SoundboardWeb.TwitchIncomingChatHandler,
        SoundboardWeb.TwitchOutgoingChatHandler,
        SoundboardWeb.IncomingMessageHandler,
        SoundboardWeb.Hue,
        SoundboardWeb.PeriodicMessage,
        SoundboardWeb.WebhookPubSub,
        SoundboardWeb.ObsWebsocket
      ]
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, restart: :transient]
    {:ok, pid} = Soundboard.DynamicSupervisor.start_link([])

    Soundboard.DynamicSupervisor.start_child(Finch, [name: SoundboardFinch])
    Enum.map(children, fn(child) ->
      Soundboard.DynamicSupervisor.start_child(child)
    end)
    {:ok, pid}
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SoundboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
