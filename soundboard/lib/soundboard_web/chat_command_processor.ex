defmodule SoundboardWeb.ChatCommandProcessor do
  def process_message_for_user("malgasm", message) do
    user = "malgasm"
    case message do
      "sherad" ->
        SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event("awaken")
        send_message("YO! Go check the MOST AMAZING lady Fallout 76 streamer! Do it now!! https://twitch.tv/stokintheneighbors malgasLove malgasLove malgasLove")
      #commands may not start with a slash
      _ -> process_message_for_user("@malgasm", message)
    end

    if String.starts_with?(message, "addcmd") do
      process_add_command(user, message)
    end

    if String.starts_with?(message, "delcmd") do
      process_remove_command(user, message)
    end
  end

  def process_message_for_user(user, message) do
    IO.puts "received a message from #{user}"
    sanitized_message = String.downcase(message)

    SoundboardWeb.CustomCommandsHelper.match_and_process_commands(user, message)

    case sanitized_message do
      "<3" -> send_message("malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove malgasLove")
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
      "420" -> play_sound("bonghit")
      "!so shroud" -> send_message("NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO")
      "!shoutout shroud" -> send_message("NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO")
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

  defp process_add_command(user, message) do
  end

  defp process_remove_command(user, message) do
  end
end
