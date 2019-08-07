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

  def add_command(command, username) do
    result = parse_command_string(command)
    if result do
      process_comamnd_add(result, username)
      "ok"
    else
      "#{username} addcmd format: addcmd command message:hello sound:wow1"
    end
    #parse the string to get the command
    #add it to yaml
    #save
  end

  defp process_comamnd_add(%{type: command_type, matching_text: matching_text, actions: command_actions}, username) do
    IO.puts "adding command #{matching_text} of type #{command_type} with #{Kernel.length(command_actions)} actions"
    actions = Enum.map(command_actions, fn(action) ->
      type = String.split(action, ":") |> Enum.at(0)
      value = String.split(action, ":") |> Enum.at(1)
      %{"#{type}": value}
    end)
    new_command = %{
      matching_text: matching_text,
      type: command_type,
      added_by: username,
      command: actions
    }
    commands = load_commands["commands"] ++ [new_command]
    save_commands %{"commands": commands}
  end

  def remove_command(command, username) do
    parse_command_string(command)
    #parse the string to get the command
    #remove it from the yaml
    #save
  end

  def list_commands do
    load_commands["commands"]
    |> Enum.map(fn (cmd) -> cmd["matching_text"] end)
  end

  defp parse_command_string(command_string) do
    command_args = String.split(command_string, " ")
    IO.puts "COMMAND ARG LENGTH #{Kernel.length(command_args)}"
    IO.inspect command_args

    if Kernel.length(command_args) < 3 do
      nil
    else
      new_command = command_name_from_command_text(Enum.at(command_args, 1)) |> String.trim()
      command_type = command_type_from_command_text(Enum.at(command_args, 1)) |> String.trim()

      command_actions = Enum.slice(command_args, 2, 100)
      IO.puts "command_actions"
      IO.inspect command_actions
      IO.puts "new_command"
      IO.puts new_command
      %{type: command_type, matching_text: new_command, actions: command_actions}
    end
  end

  defp command_type_from_command_text(command_name) do
    type = String.split(command_name, ":") |> Enum.at(1)
    if type == nil do
      "start"
    else
      type
    end
  end

  defp command_name_from_command_text(command_name) do
    String.split(command_name, ":") |> Enum.at(0)
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
        process_command_actions(Map.merge(command, %{"user" =>  user, "original_message" => message}))
      end
    end
  end


  defp process_commands("end", commands, user, message) do
    Enum.each commands, fn(command) ->
      if String.ends_with?(sanitize_message(message), command["matching_text"]) do
        process_command_actions(Map.merge(command, %{"user" =>  user, "original_message" => message}))
      end
    end
  end

  defp process_commands("anywhere", commands, user, message) do
    Enum.each commands, fn(command) ->
      if String.contains?(sanitize_message(message), command["matching_text"]) do
        process_command_actions(Map.merge(command, %{"user" =>  user, "original_message" => message}))
      end
    end
  end

  defp process_command_actions(command) do
    Enum.each command["command"], fn(cmd) ->
      process_command_action(cmd, command)
    end
  end

  defp sanitize_message(message), do: String.downcase(message)

  defp process_command_action(%{"message" => message}, command) do
    SoundboardWeb.MessagingHelper.send_twitch_chat_message(substitute_variables(message, command["user"], command["original_message"], command["matching_text"]))
  end

  defp process_command_action(%{"sound" => sound}, command) do
    if String.contains?(sound, ",") do
      SoundboardWeb.Sounds.get_random_sound(String.split(sound, ","))
      |> SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event
    else
      SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event(sound)
    end
  end

  defp process_command_action(%{"random_sound" => sound}, command) do
    IO.puts "process_command_action for random sound #{sound}"
  end

  defp substitute_variables(message, user, original_message, matching_text) do
    String.replace(message, "$sender", user)
    |> String.replace("$arg", String.replace(original_message, matching_text, ""))
  end
end
