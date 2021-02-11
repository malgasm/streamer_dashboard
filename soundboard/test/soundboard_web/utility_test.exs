defmodule SoundboardWeb.UtilityTest do
  use ExUnit.Case, async: false
  import Mock

  setup_with_mocks([
    {SoundboardWeb.BetterTTV, [], [
      emote_codes: fn() -> ["widepeepoHappy"] end,
      emote_url: fn(_) -> "https://www.better.ttv" end,
      is_emote?: fn(code) ->
        if code == "widepeepoHappy" do
          true
        else
          false
        end
      end
    ]
    },
    {SoundboardWeb.Frankerfacez, [], [
      emote_codes: fn() -> ["HYPERCLAP"] end,
      emote_url: fn(_) -> "https://www.franker.facez" end,
      is_emote?: fn(code) ->
        if code == "HYPERCLAP" do
          true
        else
          false
        end
      end
    ]}
  ]) do
    :ok
  end

  test "get_emote_usage returns emotes for a message" do
    assert SoundboardWeb.Utility.get_emote_usage("widepeepoHappy HYPERCLAP widepeepoHappy HYPERCLAP widepeepoHappy HYPERCLAP widepeepoHappy HYPERCLAP Notanemote blah blah widepeepoHappy") ==
      "https://www.franker.facez|15-24,40-49,65-74,90-99;https://www.better.ttv|0-14,25-39,50-64,75-89,121-135"
  end
end
