defmodule SoundboardWeb.BetterTTV do
  require Logger

  @api_base_url "https://api.betterttv.net/3/cached/users/twitch/"
  @image_base_url "https://cdn.betterttv.net/emote/"
  @bucket_name "BETTERTTV_EMOTES"

  def fetch_emotes_for_channel(channel_id) do
    parse_response(Finch.build(:get, @api_base_url <> channel_id) |> Finch.request(SoundboardFinch))
  end

  defp parse_response({:ok, %Finch.Response{body: body}}) do
    parsed = Jason.decode!(body)["sharedEmotes"]
    KV.Bucket.put(@bucket_name, parsed)
    parsed
  end

  defp parse_response({:error, err}) do
    Logger.error("BetterTTV: Error fetching emotes: #{inspect err}")
    err
  end

  def is_emote?(emote_code), do: Enum.member?(emote_codes(), emote_code)

  defp emotes(), do: KV.Bucket.get(@bucket_name) || []

  def emote_codes() do
    Enum.map(emotes(), fn(emote_obj) -> emote_obj["code"] end)
  end

  def detect_emotes_and_notify(message) do
    detect_emotes(message)
    |> Enum.map(fn(emote) ->
      SoundboardWeb.MessagingHelper.broadcast_new_animation_event(emote.url, emote.count)
    end)
  end

  defp detect_emotes(message) do
    used_emotes = SoundboardWeb.Utility.intersect(emote_codes, String.split(message, " "))
    Enum.map(used_emotes, fn(emote) ->
      %{
        url: emote_url(emote),
        count: SoundboardWeb.Utility.find_occurrences(emote, message)
      }
    end)
  end

  def emote_url(code, size \\ "3") do
    id = (Enum.filter(emotes(), fn(emote) -> emote["code"] == code end) |> Enum.at(0))["id"]
    @image_base_url <> id <> "/" <> size <> "x"
  end
end
