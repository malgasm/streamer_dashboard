defmodule SoundboardWeb.StreamMessagesController do
  use SoundboardWeb, :controller

  #todo: paging
  def index(conn, params \\ %{}) do
    IO.inspect params
    if params["latest"] do
      render conn, "index.json", messages: SoundboardWeb.StreamMessages.latest_messages
    else
      render conn, "index.json", messages: SoundboardWeb.StreamMessages.all_messages
    end
  end
end
