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
    Logger.debug "message received on channel #{channel} from #{user}: #{message}"

    #send message to web clients
    SoundboardWeb.MessagingHelper.broadcast_new_twitch_message(channel, user, message)

    if user == "malgasm" && message == "<3" do
      SoundboardWeb.MessagingHelper.send_twitch_chat_message("malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove")
    end
  end
end
