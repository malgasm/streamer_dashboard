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

    sanitized_message = String.downcase(message)

    if user == "malgasm" do
      case sanitized_message do
        "<3" -> SoundboardWeb.MessagingHelper.send_twitch_chat_message("malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove")
        "sherad" -> SoundboardWeb.MessagingHelper.send_twitch_chat_message("YO! Go check the MOST AMAZING lady Fallout 76 streamer! Do it now!! https://twitch.tv/stokintheneighbors malgasLove malgasLove malgasLove")
        "medic" -> SoundboardWeb.MessagingHelper.send_twitch_chat_message("Launching nukes couldn't be more chill. Go check out Medic! He's great! https://twitch.tv/medic1556")
        _ -> nil
      end
    end

    if sanitized_message == "jango" do
      send_message("rules")
    end

    if sanitized_message == "psi" do
      send_message("guy")
    end

    if sanitized_message == "dude" do
      send_message("sup?")
    end

    if sanitized_message == "bruh" do
      send_message("cmonBruh")
    end

    if sanitized_message == "!lurk" do
      send_message("oh, you lurkin'? cool. enjoy it, #{user}.")
    end
  end

  defp send_message(msg), do: SoundboardWeb.MessagingHelper.send_twitch_chat_message(msg)

end
