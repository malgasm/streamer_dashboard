defmodule SoundboardWeb.YoutubeVideosView do
  use SoundboardWeb, :view

  def render("index.json", %{videos: videos}) do
    %{
      youtube_videos: render_many(videos, __MODULE__, "video.json", as: :video)
    }
  end

  def render("video.json", %{video: video}) do
    %{
      id: video.id,
      title: video.title,
      duration: video.duration
    }
  end
end
