defmodule SoundboardWeb.PageController do
  use SoundboardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
