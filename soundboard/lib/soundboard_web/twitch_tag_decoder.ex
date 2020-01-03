defmodule SoundboardWeb.TwitchTagDecoder do
  def parse_tags(nil), do: %{}
  def parse_tags(tags_string) do
    String.split(tags_string, ";")
    |> Enum.map(fn(item) ->
      String.split(item, "=")
    end)
    |> Enum.reduce(%{}, fn(item, acc) ->
      Map.put(acc, Enum.at(item, 0), Enum.at(item, 1))
    end)
  end
end
