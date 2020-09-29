defmodule SoundboardWeb.WebhookPubSubSupervisor do
  def init(:ok) do
    children = [
      {SoundboardWeb.WebhookPubSub, name: SoundboardWeb.WebhookPubSub},
      {DynamicSupervisor, name: SoundboardWeb.WebhookPubSubSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
