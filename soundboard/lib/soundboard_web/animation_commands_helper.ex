defmodule SoundboardWeb.AnimationCommandsHelper do
  @valid_emotes [
    "malgasGrin",
    "malgasLove",
    "malgasWoot",
    "malgasFrown",
    "malgasNoice",
    "malgasPeace",
    "malgasFire"
  ]
  def process_chat_text(username, message) do
    Enum.map(@valid_emotes, fn(emote) ->
      IO.puts "PCT #{inspect message} #{inspect emotes_count(message, emote)}"
      process_emote_animation(emote, emotes_count(message, emote))
    end)
  end

  def process_emote_animation(emote, 0) do
    IO.puts "process_emote_animation zero state"
    nil
  end

  def process_emote_animation(emote, count) do
    SoundboardWeb.MessagingHelper.broadcast_new_animation_event(prepare_emote_text(emote), count)
  end

  defp prepare_emote_text(emote), do: String.replace(emote, "malgas", "") |> String.downcase
  defp emotes_count(text, emote), do: Kernel.length(String.split(text, emote)) - 1
end
