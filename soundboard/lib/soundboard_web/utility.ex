defmodule SoundboardWeb.Utility do
  def intersect(a, b), do: a -- (a -- b)

  def find_occurrences(emote, message) do
    count = String.split(message, emote) |> Kernel.length
    if count > 0 do
      count - 1
    else
      count
    end
  end

  def get_emote_usage(message) do
    emotes_list = Enum.concat(SoundboardWeb.BetterTTV.emote_codes(), SoundboardWeb.Frankerfacez.emote_codes())
    split = String.split(message, " ")
    {collection, acc} = Enum.map_reduce(split, "", fn message_part, acc ->
      if Enum.member?(emotes_list, message_part) do
        {occurrence_string(acc, message_part), "#{message_part} #{acc}"}
      else
        {nil, "#{message_part} #{acc}"}
      end
    end)

    emotes_map(collection)
  end

  defp emotes_map(occurrence_list) do
    {_, res} = Enum.reject(occurrence_list, &is_nil/1)
    |> Enum.map_reduce(%{}, fn occurrence, acc ->
      [emote, range] = String.split(occurrence, ":")

      if emote_already_used(emote, acc) do
        {nil,append_emote_to_map(emote, acc, range)}
      else
        {nil,Map.put(acc, emote, "#{range}")}
      end
    end)
    apply_urls(res)
  end

  defp apply_urls(emote_map) do
    emotes = Map.keys(emote_map)
    Enum.map(emotes, fn (emote_code) ->
      if SoundboardWeb.Frankerfacez.is_emote?(emote_code) do
        SoundboardWeb.Frankerfacez.emote_url(emote_code, "1") <> "|" <> Map.fetch!(emote_map, emote_code)
      else
        SoundboardWeb.BetterTTV.emote_url(emote_code, "1") <> "|" <> Map.fetch!(emote_map, emote_code)
      end
    end)
    |> Enum.join(";")
  end

  defp occurrence_string(acc, message_part) do
    "#{message_part}:#{String.length(acc)}-#{String.length(acc)+String.length(message_part)}"
  end

  defp emotes_from_map(acc, message_part) do
  end

  defp append_emote_to_map(message_part, acc, range) do
    Map.put(acc, message_part, Map.fetch!(acc, message_part) <> "," <> range)
  end

  defp emote_already_used(word, acc) do
    handle_fetch_result(Map.fetch(acc, word))
  end

  defp handle_fetch_result({:ok, _res}), do: true
  defp handle_fetch_result(_res), do: false
end
