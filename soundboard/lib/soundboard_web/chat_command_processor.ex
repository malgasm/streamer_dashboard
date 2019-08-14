defmodule SoundboardWeb.ChatCommandProcessor do
  def process_message_for_user(%{username: "malshypeman", isMod: isMod, isSub: isSub}, message), do: nil
  def process_message_for_user(%{username: "MalsHypeMan", isMod: isMod, isSub: isSub}, message), do: nil
  def process_message_for_user(%{username: "malgasm", isMod: isMod, isSub: isSub}, message) do
    IO.puts "PMFU MALGASM"
    user = "malgasm"
    case message do
      _ -> process_message_for_user(%{username: "@malgasm", isMod: true, isSub: true}, message)
    end

  end

  #subs only
  def process_message_for_user(%{username: username, isMod: false, isSub: true}, message) do
    if !process_sub_commands(username, message) do
      process_message_for_user(%{username: username, isMod: false, isSub: false}, message)
    end
  end

  #mods only
  def process_message_for_user(%{username: username, isMod: true, isSub: false}, message) do
    if !process_mod_commands(username, message) do
      process_message_for_user(%{username: username, isMod: false, isSub: false}, message)
    end
  end

  #subs and mods
  def process_message_for_user(%{username: username, isMod: true, isSub: true}, message) do
    if !process_mod_commands(username, message) && !process_sub_commands(username, message) do
      process_message_for_user(%{username: username, isMod: false, isSub: false}, message)
    end
  end

  defp process_sub_commands(username, message) do
    case sanitize_message(message) do
      # "status" ->
      #   send_message("cmonBruh")
      #   true
      _ -> false
    end
  end

  defp process_mod_commands(username, message) do
    #addcmd blah sound:awaken message:shtup
    if String.starts_with?(message, "!addcmd") do
      if result = SoundboardWeb.CustomCommandsHelper.add_command(message, username) do
        send_message result
      end
    end

    if String.starts_with?(message, "!sounds") do
      send_message("#{username} sounds: " <> Enum.join(SoundboardWeb.Sounds.get_sound_names, ","))
    end

    if String.starts_with?(message, "!delcmd") do
      send_message SoundboardWeb.CustomCommandsHelper.remove_command(message, username)
    end

    case sanitize_message(message) do
      # "status" ->
      #   send_message("@#{username}, you're a mod and a sub.")
      #   true
      _ -> false
    end
  end

  defp sanitize_message(msg), do: String.downcase(msg)

  def process_message_for_user(%{username: username, isMod: isMod, isSub: isSub}, message) do
    IO.puts "PMFU #{username}"
    IO.puts "received a message from #{username}"
    sanitized_message = sanitize_message(message)

    SoundboardWeb.CustomCommandsHelper.match_and_process_commands(username, message)

    case sanitized_message do
      "!so shroud" -> send_message("NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO")
      "!shoutout shroud" -> send_message("NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO")
      "!commands" -> send_message("commands: " <> commands_for_chat_list <> ", mods only: #{mod_commands}")
      "!variables" -> send_message("variables for commands: $sender (whoever runs the command) | $msg (the supplied message)")
      "gimme the codes" -> send_message(SoundboardWeb.NukaCrypt.get_nukacrypt_code_text)
      _ -> nil
    end
  end

  defp send_message(msg), do: SoundboardWeb.MessagingHelper.send_twitch_chat_message(msg)
  defp play_sound(sound), do: SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event(sound)

  defp process_add_command(user, message) do
    send_message("trying to add a command, #{user}? #{message}")
  end

  defp process_remove_command(user, message) do
  end

  defp commands_for_chat_list do
    SoundboardWeb.CustomCommandsHelper.list_commands
    |> Enum.filter(fn(cmd) ->
      String.starts_with?(cmd, "!")
    end)
    |> Enum.join(", ")
  end

  defp mod_commands do
    "!addcmd, !delcmd, !sounds, !variables"
  end
end
