defmodule SoundboardWeb.Youtube do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.googleapis.com/youtube/v3"
  plug Tesla.Middleware.Query, [key: System.get_env("YOUTUBE_API_KEY")]
  plug Tesla.Middleware.JSON

  def get_video_info(video_id) do
    youtube_api_video_info(ensure_video_id(video_id))
    |> parse_video_info_response(video_id)
  end

  defp parse_video_info_response({:ok, response}, video_id) do
    %{
      id: video_id,
      title: Enum.at(response.body["items"], 0)["snippet"]["title"],
      duration: Enum.at(response.body["items"], 0)["contentDetails"]["duration"]
    }
  end

  defp parse_video_info_response({:error, message}, video_id) do
    IO.puts "uh oh. something went wrong trying to fetch a youtube video!"
    IO.inspect message
  end

  defp youtube_api_video_info(video_id) do
    get("/videos?part=snippet,contentDetails&id=" <> video_id)
  end

  defp ensure_video_id(video_id) do
    parsed = URI.parse(String.strip(video_id))

    case parsed.host do
      "www.youtube.com" ->
        IO.inspect parsed
        parsed_query = URI.decode_query(parsed.query)
        IO.inspect parsed_query
        parsed_query["v"]
      "youtu.be" ->
        String.slice(parsed.path, 1, String.length(parsed.path))
      _ ->
        IO.puts "returning default #{video_id}"
        video_id
    end
  end
end
