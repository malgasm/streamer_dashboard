defmodule SoundboardWeb.TwitchPubSub do
  use WebSockex
  require Logger
	@server "wss://pubsub-edge.twitch.tv"
  @topics Application.get_env(:soundboard, :twitch_pubsub_topics)
  @ping_pong_delay 1 * 20 * 1000

  def start_link(opts \\ []) do
    {:ok, pid} = WebSockex.start_link(@server, __MODULE__, opts)
    subscribe_to_twitch(pid)
    KV.Bucket.put(:streamer_dashboard, "PUBSUB_PID", pid)
    ping_pong(pid)
    {:ok, pid}
  end

  def echo(client, message) do
    Logger.info("Sending message: #{message}")
    WebSockex.send_frame(client, {:text, message})
  end

  def handle_connect(_conn, state) do
    Logger.info("Twitch Websocket Connected")
    {:ok, state}
  end

  def handle_frame({:text, msg}, state) do
    handle_twitch_pubsub_message({Poison.decode!(msg), state})
  end

  def handle_twitch_pubsub_message({%{"type" => "PONG"}, state}) do
    Logger.info("PONG received")
    KV.Bucket.put(:streamer_dashboard, "PUBSUB_PONG_RECEIVED", "true")
    Process.send_after(self(), :ping_pong, @ping_pong_delay)
    {:ok, state}
  end

  def handle_twitch_pubsub_message({%{"message" => %{"data" => %{"type" => type, "data" => data}}}, state}) do
    IO.puts "Twitch PubSub typed message received - #{inspect type} Data: #{inspect data}"
    {:ok, state}
  end

  def handle_twitch_pubsub_message({msg, state}) do
    IO.puts "Twitch PubSub received message -- Message: #{inspect msg}"
    IO.puts "Twitch PubSub received message -- Message: #{inspect msg["type"]}"
    IO.puts "state: #{state}"
    {:ok, state}
  end

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    #catch ping
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Twitch Websocket disconnected. reason: #{inspect reason}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  def handle_info(:ping_pong, state) do
    Logger.info("Twitch Websocket: sending PING")
    {:reply, {:text, ping_message_body}, state}
  end

  def handle_info(:reconnect_if_no_pong, state) do
    if KV.Bucket.get(:streamer_dashboard, "PUBSUB_PONG_RECEIVED") == nil do
      Kernel.send(self(), :start_link)
    end
  end

  def subscribe_to_twitch(pid) do
    data = Poison.encode!(twitch_subscription_message_body())
    echo(pid, data)
    Logger.info("Twitch PubSub subscribed to topics #{inspect @topics}")
  end

  def twitch_subscription_message_body do
    %{
      type: "LISTEN",
      nonce: "nonce" <> Integer.to_string(:rand.uniform(1000000000)),
      data: %{
        topics: @topics,
        auth_token: Application.get_env(:soundboard, :twitch_oauth_key_websocket)
      }
    }
  end

  def ping_pong(pid) do
    Logger.info("Sending PING")
    echo(pid, ping_message_body)
    KV.Bucket.delete(:streamer_dashboard, "PUBSUB_PONG_RECEIVED")
    Process.send_after(self(), :reconnect_if_no_pong, 10 * 1000)
  end

  def ping_message_body do
    Poison.encode!(%{
      type: "PING"
    })
  end
end
