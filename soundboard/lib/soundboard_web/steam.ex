defmodule SoundboardWeb.Steam do
  require Logger
  @steamid_url_base "http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001/"

  @userinfo_url_base "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/"

  #?key=75D7DE618932DC18E9471DBFBFDB3804&steamids=76561197963341073"


  def get_steamid(vanity_url) do
    query_params = "?key=#{System.get_env("STEAM_API_KEY")}&vanityurl=#{vanity_url}"

    parse_steamid_response(Finch.build(:get, @steamid_url_base <> query_params) |> Finch.request(SoundboardFinch))
  end

  defp parse_steamid_response({:ok, %Finch.Response{body: body}}), do: steamid_from_response(Jason.decode!(body))

  defp steamid_from_response(%{"response" => %{"steamid" => steam_id}}), do: steam_id
  defp steamid_from_response(%{"response" => %{"message" => msg}}), do: msg

  defp parse_response({:error, err}) do
    Logger.error("Frankerfacez: Error fetching emotes: #{inspect err}")
    err
  end
end
