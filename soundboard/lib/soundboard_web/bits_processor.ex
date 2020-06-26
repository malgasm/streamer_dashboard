defmodule SoundboardWeb.BitsProcessor do

  def load_bits_actions do
    {:ok, bits_actions} = SoundboardWeb.Filesystem.read_file("bits_actions/bits_actions.yml")
    |> YamlElixir.read_from_string

    bits_actions
  end

  def save_bits_actions(bits_actions) when is_map(bits_actions)  do
    Yamlix.dump(bits_actions)
    |> SoundboardWeb.Filesystem.write_file("bits_actions/bits_actions.yml")
  end

  def bits_action_by_bits(bits) do
    Enum.find(load_bits_actions["bits_actions"], fn(action) -> action["quantity"] == bits end)
  end

  defp send_message(msg), do: SoundboardWeb.MessagingHelper.send_twitch_chat_message(msg)

  # - amount
  # - actions
  #   - blah
  #   - blah
  #   - and so on

  def process_message_for_user(user, message) do
    if user.bits && user.bits > 0 do
      #todo: include username in #bits_action_by_bits
      bits_action = bits_action_by_bits(String.to_integer(user.bits))
      process_bits_actions(bits_action["actions"])
    end
  end

  def process_bits_actions(bits_actions) do
    Enum.each bits_actions, fn(bits_action) ->
      IO.puts "PBA bits_action"
      IO.inspect bits_action
      process_bits_action(bits_action)
    end
  end

  def process_bits_action(%{"sound" => sound}) do
    #todo: maybe abstract this code which is shared with the custom command processor
    if String.contains?(sound, ",") do
      SoundboardWeb.Sounds.get_random_sound(String.split(sound, ","))
      |> SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event
    else
      SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event(sound)
    end
  end

end
