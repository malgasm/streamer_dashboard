defmodule SoundboardWeb.SoundsController do
  use SoundboardWeb, :controller

  def index(conn, params \\ %{}) do
    #load sound files from somewhere (yaml?) and send them to the client
    render conn, "index.json", sounds: SoundboardWeb.Sounds.get_sounds
  end
end
