defmodule SoundboardWeb.IncomingMessageHandler do
  use GenServer
  require Logger

  #todo: yaml-ize the commands here
  # important points of data:
  # - user with access to commands
  # - name of command
  # - command message
  # - matching (beginning, end, any)
  #
  # commands.yaml
  #
  # commands:
  #   - command: '!hug'
  #     message: 'barf'
  #     matching: 'beginning'
  #   - command: '!lurk'
  #     message: 'you are lurking $username'
  #     matching: ''

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

    process_message_for_user(user, message)
  end

  defp process_message_for_user("malgasm", message) do
    IO.puts "received a message from malgasm :o"
    case message do
      _ -> process_message_for_user("bruh", message)
    end
  end

  defp process_message_for_user(user, message) do
    IO.puts "received a message from #{user}"
    sanitized_message = String.downcase(message)

    case sanitized_message do
      "<3" -> send_message("malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove")
      "sherad" ->
        SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event("awaken")
        send_message("YO! Go check the MOST AMAZING lady Fallout 76 streamer! Do it now!! https://twitch.tv/stokintheneighbors malgasLove malgasLove malgasLove")
      "medic" -> send_message("Launching nukes couldn't be more chill. Go check out Medic! He's great! https://twitch.tv/medic1556")
      "hondo" -> send_message("Fantastic Fallout 76 and fun times - go check out BossHondo! https://twitch.tv/bosshondo")
      "sooner" ->
        play_sound("sooner")
        send_message("Go check out SoonerChemical - Twitch's most awesome variety streamer! https://twitch.tv/soonerchemical")
      "discord" -> send_message("Join malgasm's Chatgasm at https://discord.gg/hkP56Et malgasLove")
      "jango" -> send_message("rules")
      "psi" -> send_message("guy")
      "dude" -> send_message("sup?")
      "bruh" -> send_message("cmonBruh")
      "huzzah" -> play_sound("applause")
      "gimme the codes" -> send_message(SoundboardWeb.NukaCrypt.get_nukacrypt_code_text)
      _ -> nil
    end

    if String.starts_with?(sanitized_message, "!hug") do
      send_message("barf")
    end

    if String.contains?(sanitized_message, "gay") do
      SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event("everyonesgay")
    end

    if String.starts_with?(sanitized_message, "hi") do
      send_message("hi #{user}!")
    end
  end

  defp send_message(msg), do: SoundboardWeb.MessagingHelper.send_twitch_chat_message(msg)
  defp play_sound(sound), do: SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event(sound)
end
