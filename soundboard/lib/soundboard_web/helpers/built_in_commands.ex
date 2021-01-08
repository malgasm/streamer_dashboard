defmodule SoundboardWeb.BuiltInCommandsHelper do
  require Logger
  import SoundboardWeb.ChatCommandProcessor

  def process_built_in_command(username, message) do
    case message do
      "!commands" -> send_message("commands: " <> commands_for_chat_list <> ", mods only: #{mod_commands}")
      "!variables" -> send_message("variables for commands: $sender (whoever runs the command) | $msg (the supplied message)")
      "gimme the codes" -> send_message(SoundboardWeb.NukaCrypt.get_nukacrypt_code_text)
      _ -> nil
    end
  end

  defp send_message(msg), do: SoundboardWeb.MessagingHelper.send_twitch_chat_message(msg)
end
