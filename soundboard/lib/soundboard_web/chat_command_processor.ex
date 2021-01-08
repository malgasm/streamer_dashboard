defmodule SoundboardWeb.ChatCommandProcessor do
  require Logger

  def process_message_for_user(%{username: "malshypeman", isMod: isMod, isSub: isSub}, message), do: nil
  def process_message_for_user(%{username: "MalsHypeMan", isMod: isMod, isSub: isSub}, message), do: nil
  def process_message_for_user(%{username: "malgasm", isMod: isMod, isSub: isSub}, message) do
    user = System.get_env("TWITCH_USERNAME_INCOMING")
    case message do
      _ -> process_message_for_user(%{username: "@" <> user, isMod: true, isSub: true}, message)
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
    #todo: add control around stopping or continuing the processing of these commands.
    #currently this method will only respect the final conditional
    if String.starts_with?(message, "!authorize") do
      result = SoundboardWeb.ProcessHelper.call_process(SoundboardWeb.Hue, {:authorize})
      if result == true do
        send_message("SeemsGood")
      else
        send_message(result)
      end
    end

    if String.starts_with?(message, "!addcmd") do
      if result = SoundboardWeb.CustomCommandsHelper.add_command(message, username) do
        send_message result
      end
    end

    if String.starts_with?(message, "!spam") do
      sanitized = String.replace(message, "!spam", "")
                  |> String.trim()

      args = String.split(sanitized, " ")

      if Kernel.length(args) > 1 do
        num_times = List.first(args)

        num_times = try do
          String.to_integer(num_times)
        rescue
          RuntimeError ->
            Logger.debug "error parsing #{num_times} as an integer"
            List.first(args)
        end

        to_spam = String.replace(sanitized, List.first(args), "")
                  |> String.trim()

        Logger.debug "spamming #{to_spam} #{num_times} times"

        process_spam(num_times, to_spam)
      end
    end

    if String.starts_with?(message, "!sounds") do
      send_message("#{username} sounds: " <> Enum.join(SoundboardWeb.Sounds.get_sound_names, ","))
    end

    if String.starts_with?(message, "!delcmd") do
      send_message SoundboardWeb.CustomCommandsHelper.remove_command(message, username)
    end

    # case sanitize_message(message) do
    #   "spam" ->
    #     true
    #   _ -> false
    # end
  end

  defp process_spam(num_times, to_spam) when is_integer(num_times) do
    Enum.each(1..num_times, fn x ->
      Logger.debug "sending message #{to_spam}"
      send_message to_spam
    end)
  end

  defp process_spam(num_times, to_spam) do
    Logger.error "Error processing !spam command. Invalid arguments."
    send_message "NOPERS"
  end

  defp sanitize_message(msg), do: String.downcase(msg)

  def process_message_for_user(%{username: username, isMod: isMod, isSub: isSub}, message) do
    IO.puts "PMFU #{username}"
    IO.puts "received a message from #{username}"
    sanitized_message = sanitize_message(message)

    SoundboardWeb.CustomCommandsHelper.match_and_process_commands(username, message)
    SoundboardWeb.BuiltInCommandsHelper.process_built_in_command(username, message)
  end

  def commands_for_chat_list do
    SoundboardWeb.CustomCommandsHelper.list_commands
    |> Enum.filter(fn(cmd) ->
      String.starts_with?(cmd, "!")
    end)
    |> Enum.join(", ")
  end

  def mod_commands do
    "!addcmd, !delcmd, !sounds, !variables"
  end

  defp send_message(msg), do: SoundboardWeb.MessagingHelper.send_twitch_chat_message(msg)
  defp play_sound(sound), do: SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event(sound)

  defp process_add_command(user, message) do
    send_message("trying to add a command, #{user}? #{message}")
  end

  defp process_remove_command(user, message) do
  end
end
