defmodule SoundboardWeb.StreamSessionChannel do
  use Phoenix.Channel

  def join("stream_session:lobby", _message, socket) do
    {:ok, socket}
  end

  def handle_in("play_sound", %{"sound_id" => sound_id}, socket) do
    broadcast!(socket, "play_sound", %{sound_id: sound_id})
    {:noreply, socket}
  end

  def handle_in("shout_out", %{"username" => username}, socket) do
    broadcast!(socket, "shout_out", %{username: username})
    {:noreply, socket}
  end
end
