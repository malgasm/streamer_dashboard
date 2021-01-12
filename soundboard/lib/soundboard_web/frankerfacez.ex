defmodule SoundboardWeb.Frankerfacez do
  require Logger
  @api_base_url "https://api.frankerfacez.com/v1/room/"
  @bucket_name "FRANKERFACEZ_EMOTES"

  def fetch_emotes() do
    parse_response(Finch.build(:get, @api_base_url <> Application.get_env(:soundboard, :twitch_incoming_nick)) |> Finch.request(SoundboardFinch))
  end

  defp parse_response({:ok, %Finch.Response{body: body}}) do
    parsed = Jason.decode!(body)
    sets = parsed["sets"]
    {_, results} = Enum.take(sets, 1) |> Enum.at(0)

    KV.Bucket.put(@bucket_name, results["emoticons"])
    results["emoticons"]
  end

  defp emotes(), do: KV.Bucket.get(@bucket_name) || []

  def emote_codes() do
    Enum.map(emotes(), fn(emote_obj) -> emote_obj["name"] end)
  end

  defp parse_response({:error, err}) do
    Logger.error("Frankerfacez: Error fetching emotes: #{inspect err}")
    err
  end

  def detect_emotes_and_notify(message) do
    detect_emotes(message)
    |> Enum.map(fn(emote) ->
      IO.inspect emote
      SoundboardWeb.MessagingHelper.broadcast_new_animation_event(emote.url, emote.count)
    end)
  end

  def detect_emotes(message) do
    used_emotes = SoundboardWeb.Utility.intersect(emote_codes, String.split(message, " "))
    Enum.map(used_emotes, fn(emote) ->
      %{
        url: emote_url(emote),
        count: SoundboardWeb.Utility.find_occurrences(emote, message)
      }
    end)
  end

  defp emote_url(code, size \\ "4") do
    emote = (Enum.filter(emotes(), fn(emote) -> emote["name"] == code end) |> Enum.at(0))
    if emote["urls"][size] do
      "https:" <> emote["urls"][size]
    else
      "https:" <> emote["urls"]["1"]
    end
  end
end
