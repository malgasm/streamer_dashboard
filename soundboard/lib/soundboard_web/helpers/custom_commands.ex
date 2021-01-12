defmodule SoundboardWeb.CustomCommandsHelper do
  require Logger
  defp valid_command_types, do: ["start", "anywhere", "exact"]
  defp valid_command_actions, do: ["message", "sound", "animation"]

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
    parsed_command = parse_command_string(command)
    if parsed_command && process_command_add(parsed_command, username) do
      if user_has_permission_to_modify_command(parsed_command.matching_text, username) do
        "#{username} command #{parsed_command.matching_text} added with #{Kernel.length(parsed_command.actions)} actions."
      else
        "#{username}, only #{find_existing_command(%{matching_text: parsed_command.matching_text})["added_by"]} has permission to modify that command."
      end
    else
      "#{username} to add a command: !addcmd command message:hello;sound:wow1"
    end
  end

  defp process_command_add(%{type: command_type, matching_text: matching_text, actions: command_actions}, username) do
    if user_has_permission_to_modify_command(matching_text, username) &&
      command_is_valid(matching_text, command_type, command_actions) do
      actions = Enum.map(command_actions, fn(action) ->
        type = String.split(action, ":") |> Enum.at(0)
        value = String.split(action, ":") |> Enum.at(1)
        %{"#{type}": value}
      end)
      new_command = %{
        matching_text: matching_text,
        type: command_type,
        added_by: username |> String.downcase |> String.replace("@", ""),
        command: actions
      }
      commands = add_or_replace_command(new_command)
      save_commands %{"commands": commands}
    else
      false
    end
  end

  defp user_has_permission_to_modify_command(matching_text, username) do
    IO.puts "checking to see if #{username} has permission to modify #{matching_text}..."
    existing_command = find_existing_command(%{matching_text: matching_text})
    !existing_command || username == 'malgasm' ||
      (String.downcase(existing_command["added_by"]) |> String.replace("@", "")) == (String.downcase(username) |> String.replace("@", ""))
  end

  defp command_is_valid(matching_text, command_type, actions) do
    String.starts_with?(matching_text, "!") &&
      Enum.find_index(valid_command_types, fn(type) -> type == command_type end) != nil &&
      !Enum.any?(actions, fn(action) ->
        !String.starts_with?(action, "message:") && !String.starts_with?(action, "sound:")
      end)
  end

  defp find_existing_command(%{matching_text: matching_text}) do
    command = load_commands["commands"]
      |> Enum.filter(fn(cmd) -> cmd["matching_text"] == matching_text end)
    if command do
      Enum.at(command, 0)
    else
      nil
    end
  end

  defp add_or_replace_command(replacement_command) do
    commands = load_commands["commands"]
      |> Enum.filter(fn(cmd) -> cmd["matching_text"] != replacement_command.matching_text end)

    commands ++ [replacement_command]
  end

  def remove_command(command, username) do
    matching_text = String.split(command, " ") |> Enum.at(1)

    if String.starts_with?(matching_text, "!") && user_has_permission_to_modify_command(matching_text, username) do
      commands = load_commands["commands"]
        |> Enum.filter(fn(cmd) -> cmd["matching_text"] != matching_text end)
      save_commands %{"commands": commands}
      "command #{matching_text} was removed, #{username}."
    else
      "something went wrong while trying to remove that command. does it exist? do you have access to remove it?"
    end
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

      command_actions = Enum.slice(command_args, 2, 10000)
        |> Enum.join(" ")
        |> String.split(";")
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
    process_commands("exact", commands_by_type(commands, "exact"), user, message)
  end

  defp commands_by_type(commands, type) do
    Enum.filter(commands["commands"], fn(command) -> command["type"] == type end)
  end

  defp process_commands("start", commands, user, message) do
    Enum.each commands, fn(command) ->
      if String.starts_with?(sanitize_message(message), command["matching_text"]) do
        IO.puts "PCA #{command["matching_text"]}"
        IO.inspect command
        process_command_actions(Map.merge(command, %{"user" =>  user, "original_message" => message}))
      end
    end
  end


  defp process_commands("exact", commands, user, message) do
    Enum.each commands, fn(command) ->
      if message == command["matching_text"] do
        process_command_actions(Map.merge(command, %{"user" =>  user, "original_message" => message}))
      end
    end
  end

  defp process_commands("anywhere", commands, user, message) do
    Enum.each commands, fn(command) ->
      #Logger.debug "Custom Commands: checking input against command #{command["matching_text"]}"
      if String.contains?(sanitize_message(message), command["matching_text"]) do
        Logger.debug "Custom Commands: match found. executing command #{command["matching_text"]} for user #{user}."
        process_command_actions(Map.merge(command, %{"user" =>  user, "original_message" => message}))
      end
    end
  end

  defp process_command_actions(command) do
    Enum.each command["command"], fn(cmd) ->
      IO.puts "PCA II cmd"
      IO.inspect cmd
      process_command_action(cmd, command)
    end
  end

  defp sanitize_message(message), do: String.downcase(message)

  defp process_command_action(%{"message" => message}, command) do
    SoundboardWeb.MessagingHelper.send_twitch_chat_message(substitute_variables(message, command["user"], command["original_message"], command["matching_text"]))
  end

  defp process_command_action(%{"single-animation" => emote}, command) do
    SoundboardWeb.MessagingHelper.broadcast_new_animation_event(emote, 1)
  end

  defp process_command_action(%{"brb-direction" => direction}, command) do
    SoundboardWeb.MessagingHelper.broadcast_brb_direction_change(direction)
  end

  defp process_command_action(%{"sound" => sound}, command) do
    if String.contains?(sound, ",") do
      SoundboardWeb.Sounds.get_random_sound(String.split(sound, ","))
      |> SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event
    else
      SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event(sound)
    end
  end

  defp substitute_variables(message, user, original_message, matching_text) do
    String.replace(message, "$sender", user)
    |> String.replace("$msg", String.replace(original_message, matching_text, ""))
  end
end
