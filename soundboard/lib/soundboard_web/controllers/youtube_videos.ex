defmodule SoundboardWeb.YoutubeVideosController do
  use SoundboardWeb, :controller

  def index(conn, %{"video_id" => video_id}) do
    render conn, "index.json", videos: [SoundboardWeb.Youtube.get_video_info(video_id)]
  end

  def index(conn, _) do
    conn
    |> put_status(:not_found)
    |> send_resp(404, "")
  end
end
