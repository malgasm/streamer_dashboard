defmodule SoundboardWeb.CustomCommandsHelper do
  require Logger

  def load_commands do
    {:ok, commands} = SoundboardWeb.Filesystem.read_file("commands/commands.yml")
    |> YamlElixir.read_from_string

    commands
  end

  def save_commands(commands) when is_map(commands) do
    Yamlix.dump(commands)
    |> SoundboardWeb.Filesystem.write_file("commands/commands.yml")
  end

  def match_and_process_commands(user, message) do
    IO.puts "match_and_process_commands message #{message} from #{user}"
    #loop through each type of command (start, anywhere, end)
    #end if any command has been executed
    commands = load_commands

    process_commands("start", commands_by_type(commands, "start"), user, message)
    process_commands("anywhere", commands_by_type(commands, "anywhere"), user, message)
    process_commands("end", commands_by_type(commands, "end"), user, message)
  end

  defp commands_by_type(commands, type) do
    Enum.filter(commands["commands"], fn(command) -> command["type"] == type end)
  end

  defp process_commands("start", commands, user, message) do
    Enum.each commands, fn(command) ->
      if String.starts_with?(sanitize_message(message), command["matching_text"]) do
        process_command_actions(command["command"])
      end
    end
  end


  defp process_commands("end", commands, user, message) do
    Enum.each commands, fn(command) ->
      if String.ends_with?(sanitize_message(message), command["matching_text"]) do
        process_command_actions(command["command"])
      end
    end
  end

  defp process_commands("anywhere", commands, user, message) do
    Enum.each commands, fn(command) ->
      if String.contains?(sanitize_message(message), command["matching_text"]) do
        process_command_actions(command["command"])
      end
    end
  end

  defp process_command_actions(commands) when is_list(commands) do
    Enum.each commands, fn(command) ->
      IO.puts "PCA #{command["message"]}"
      process_command_action(command)
    end
  end

  defp sanitize_message(message), do: String.downcase(message)

  defp process_command_action(%{"message" => message}) do
    SoundboardWeb.MessagingHelper.send_twitch_chat_message(substitute_variables(message))
  end

  defp process_command_action(%{"sound" => sound}) do
    if String.contains?(sound, ",") do
      SoundboardWeb.Sounds.get_random_sound(String.split(sound, ","))
      |> SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event
    else
      SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event(sound)
    end
  end

  defp process_command_action(%{"random_sound" => sound}) do
    IO.puts "process_command_action for random sound #{sound}"
  end

  defp substitute_variables(message) do
    "hah"
  end
end
