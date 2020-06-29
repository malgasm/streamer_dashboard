defmodule SoundboardWeb.TwitchPubSub do
  use WebSockex
  require Logger
	@server "wss://pubsub-edge.twitch.tv"
  @topics Application.get_env(:soundboard, :twitch_pubsub_topics)
  @ping_pong_delay 4 * 20 * 1000

  def start_link(opts \\ []) do
    {:ok, pid} = WebSockex.start_link(@server, __MODULE__, opts)
    subscribe_to_twitch(pid)
    ping_pong(pid)
    {:ok, pid}
  end

  def echo(client, message) do
    Logger.info("Sending message: #{message}")
    WebSockex.send_frame(client, {:text, message})
  end

  def handle_connect(_conn, state) do
    Logger.info("Twitch PubSub Connected")
    {:ok, state}
  end

  def handle_frame({:text, msg}, state) do
    handle_twitch_pubsub_message({Poison.decode!(msg), state})
  end

  def handle_twitch_pubsub_message({%{"type" => "PONG"}, state}) do
    # Logger.info("PONG received")
    KV.Bucket.put(:streamer_dashboard, "PUBSUB_PONG_RECEIVED", "true")
    Process.send_after(self(), :ping_pong, @ping_pong_delay)
    {:ok, state}
  end

  def handle_twitch_pubsub_message({%{"data" => %{"message" => message}}, state}) do
    handle_typed_message({Poison.decode!(message), state})
  end

  def handle_typed_message({%{"type" => "reward-redeemed", "data" => data}, state}) do
    Logger.info("Twitch PubSub Channel Points Redemption: #{get_reward_title(data)} by #{get_reward_user(data)} #{get_reward_entered_text(data)}")

    SoundboardWeb.ProcessHelper.send_process(
      SoundboardWeb.SpecialEventHandler,
      {:channel_points_redemption,
        %{
          username: get_reward_user(data),
          redemption: get_reward_title(data),
          entered_text: get_reward_entered_text(data)
        }
      }
    )
    {:ok, state}
  end

  def get_reward_title(reward_message_data) do
    reward_message_data["redemption"]["reward"]["title"]
  end

  def get_reward_user(reward_message_data) do
    reward_message_data["redemption"]["user"]["display_name"]
  end

  def get_reward_entered_text(reward_message_data) do
    reward_message_data["redemption"]["user_input"]
  end

  def handle_typed_message({%{"type" => "reward-redeemed", "data" => data}, state}) do
    Logger.info("Twitch PubSub handle_typed_message D:")
    {:ok, state}
  end

  def handle_twitch_pubsub_message({msg, state}) do
    IO.puts "Twitch PubSub received message -- Message: #{inspect msg}"
    IO.puts "Twitch PubSub received message -- Message: #{inspect msg["data"]}"
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
    Logger.info("Twitch PubSub disconnected. reason: #{inspect reason}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  def handle_info(:ping_pong, state) do
    # Logger.info("Twitch PubSub: sending PING")
    Process.send_after(self(), :reconnect_if_no_pong, 10 * 1000)
    {:reply, {:text, ping_message_body}, state}
  end

  def handle_info(:reconnect_if_no_pong, state) do
    if KV.Bucket.get(:streamer_dashboard, "PUBSUB_PONG_RECEIVED") == nil do
      # Logger.info("Twitch PubSub: ten seconds has expired and we haven't received a PONG response. Restarting.")
      Kernel.send(self(), :start_link)
    else
      # Logger.info("Twitch PubSub: ten seconds has expired and we've received a PONG malgasWoot")
    end
    {:ok, state}
  end

  def handle_info(param, state) do
    Logger.info("Twitch PubSub: UNHANDLED handle_info: #{inspect param}")
    {:ok, state}
  end

  def subscribe_to_twitch(pid) do
    data = twitch_subscription_message_body()
    echo(pid, data)
    Logger.info("Twitch PubSub subscribed to topics #{inspect @topics}")
  end

  def twitch_subscription_message_body do
    Poison.encode!(%{
      type: "LISTEN",
      nonce: "nonce" <> Integer.to_string(:rand.uniform(1000000000)),
      data: %{
        topics: @topics,
        auth_token: Application.get_env(:soundboard, :twitch_oauth_key_pubsub)
      }
    })
  end

  def ping_pong(pid) do
    Logger.info("Twtich PubSub: Sending first PING")
    KV.Bucket.delete(:streamer_dashboard, "PUBSUB_PONG_RECEIVED")
    echo(pid, ping_message_body)
  end

  def ping_message_body do
    Poison.encode!(%{
      type: "PING"
    })
  end
end
