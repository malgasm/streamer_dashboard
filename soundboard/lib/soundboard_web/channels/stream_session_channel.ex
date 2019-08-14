defmodule SoundboardWeb.StreamSessionChannel do
  use Phoenix.Channel

  def join("stream_session:lobby", _message, socket) do
    {:ok, socket}
  end

  def handle_in("stream_action", %{"type" => type, "value" => value}, socket) do
    broadcast!(socket, "stream_action", %{type: type, value: value})
    {:noreply, socket}
  end

  def handle_in("stream_action", %{"type" => type}, socket) do
    broadcast!(socket, "stream_action", %{type: type, value: ""})
    {:noreply, socket}
  end
end
