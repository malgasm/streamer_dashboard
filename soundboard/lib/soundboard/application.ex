defmodule Soundboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
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
      SoundboardWeb.Hue
      # SoundboardWeb.PeriodicMessage,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Soundboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SoundboardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
