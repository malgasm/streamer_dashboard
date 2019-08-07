defmodule SoundboardWeb.IncomingMessageHandler do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [%{}])
  end

  def init([config]) do
    {:ok, %{}}
  end

  def handle_info({:message_sent, channel, user, message}, config) do
    process_message(channel, user, message)
    {:noreply, config}
  end

  def process_message(channel, user, message) do
    #send message to web clients
    SoundboardWeb.MessagingHelper.broadcast_new_twitch_message(channel, user, message)

    sanitized_message = String.downcase(message)

    SoundboardWeb.ChatCommandProcessor.process_message_for_user(user, message)
  end
end
