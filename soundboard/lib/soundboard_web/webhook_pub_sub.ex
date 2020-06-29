defmodule SoundboardWeb.WebhookPubSub do
  use WebSockex
  require Logger
	@server Application.get_env(:soundboard, :webhook_websocket_endpoint)
	@key Application.get_env(:soundboard, :webhook_websocket_key)
  @channel "webhooks:#{Application.get_env(:soundboard, :webhook_websocket_channel)}"

  @ping_pong_delay 4 * 20 #* 1000

  #todo: implement a channel join failure flow
  def init(_) do
    Process.flag(:trap_exit, true)
  end

  def start_link(opts \\ []) do
    extra_headers = [
      {"Authorization", Application.get_env(:soundboard, :webhook_websocket_key)}
    ]
    {:ok, pid} = WebSockex.start_link(@server, __MODULE__, %{}, extra_headers: extra_headers)
    join_channel(pid)
    # ping_pong(pid)
    {:ok, pid}
  end

  def handle_info({:EXIT, _from, reason}, state) do
    Logger.info "exiting"
    cleanup(reason, state)
    {:stop, reason, state} # see GenServer docs for other return types
  end

  def terminate(reason, state) do
    Logger.info "terminating reason #{inspect reason} state #{inspect state}"
    cleanup(reason, state)
    state
  end

  defp cleanup(_reason, _state) do
    Kernel.send(self(), :start_link)
    # Cleanup whatever you need cleaned up
  end

  def echo(client, message) do
    Logger.info("Webhook: Sending message: #{message}")
    WebSockex.send_frame(client, {:text, message})
  end

  def handle_terminate_close(_conn, state) do
    Logger.info("Webhook PubSub Terminated!")
    {:ok, state}
  end

  def handle_connect(_conn, state) do
    Logger.info("Webhook PubSub Connected")
    {:ok, state}
  end

  def handle_frame({:text, %{"event": "phx_reply", "payload": payload, "ref": ref}}, state) do
    IO.puts "Webhook received phx_reply payload: #{inspect payload} ref: #{inspect ref}"
    {:ok, state}
  end

  def handle_frame({:text, %{event: "NEW_MESSAGE"}}, state) do
    IO.puts "huh?"
    {:ok, state}
  end

  def handle_frame({:text, %{"event": "NEW_MESSAGE", "payload": payload, "ref": ref}}, state) do
    IO.inspect "new message #{inspect Jason.decode!(payload)}"
    {:ok, state}
  end

  def handle_frame({:text, msg}, state) do
    IO.puts "Webhook handle_frame :text #{inspect msg}"
    try do
      decoded = Poison.decode!(msg)
      IO.inspect decoded

      handle_webhook_pubsub_message({decoded["event"], decoded["payload"], decoded["ref"]}, state)
    rescue e in RuntimeError -> e
      IO.puts "ran into an error decoding the response"
      {:ok, state}
    end
  end

  def handle_frame(msg, state) do
    IO.puts "Webhook handle_frame #{inspect msg}"
    {:ok, state}
  end

  def handle_webhook_pubsub_message({%{"event" => "NEW_MESSAGE", "payload" => payload}, state}) do
    IO.inspect "new message #{inspect payload}"
    {:ok, state}
  end

  def handle_webhook_pubsub_message({%{"data" => %{"message" => message}}, state}) do
    IO.puts "Webhook PubSub received message with data -- Message: #{inspect message}"
  end

  def handle_webhook_pubsub_message({"NEW_MESSAGE", payload, ref}, state) do
    IO.puts "new_message pls #{inspect Jason.decode!(payload["message"])}"
    {:ok, state}
  end

  def handle_webhook_pubsub_message({"phx_reply", %{"response" => %{"event" => "PONG"}}, ref}, state) do
    IO.puts "we def received a pong"
    KV.Bucket.put(:streamer_dashboard, "WEBHOOK_PUBSUB_PONG_RECEIVED", "true")
    # Process.send_after(self(), :ping_pong, @ping_pong_delay)
    {:ok, state}
  end

  def handle_webhook_pubsub_message({event, payload, ref}, state) do
    IO.puts "handle_webhook_pubsub_message default #{inspect event}"
    {:ok, state}
  end

  # def handle_webhook_pubsub_message({msg, state}) do
  #   IO.puts "Webhook PubSub received message -- Message: #{inspect msg}"
  #   # IO.inspect Jason.decode!(msg["payload"])
  #   {:ok, state}
  # end
  #
  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    #catch ping
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Webhook: Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Webhook PubSub disconnected. reason: #{inspect reason}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  def handle_info(:ping_pong, state) do
    # Process.send_after(self(), :reconnect_if_no_pong, 10 * 1000)
    {:reply, {:text, ping_message_body}, state}
  end

  def handle_info(:reconnect_if_no_pong, state) do
    if KV.Bucket.get(:streamer_dashboard, "WEBHOOK_PUBSUB_PONG_RECEIVED") == nil do
      # Logger.info("Webhook PubSub: ten seconds has expired and we haven't received a PONG response. Restarting.")
      Kernel.send(self(), :start_link)
    else
      Logger.info("Webhook PubSub: ten seconds has expired and we've received a PONG malgasWoot")
    end
    {:ok, state}
  end

  def handle_info(param, state) do
    Logger.info("Webhook PubSub: UNHANDLED handle_info: #{inspect param}")
    {:ok, state}
  end

  def join_channel(pid) do
    data = join_channel_message_body()
    IO.puts "echo #{ inspect echo(pid, data) }"
    Logger.info("Webhook PubSub joined #{@channel}")
  end

  def join_channel_message_body do
    Poison.encode!(%{
      event: "phx_join",
      topic: @channel,
      ref: "client-#{@channel}-join-#{Integer.to_string(:rand.uniform(10000))}",
      payload: Jason.encode!(%{auth: @key})
    })
  end

  def ping_pong(pid) do
    Logger.info("Webhook: Sending PING")
    KV.Bucket.delete(:streamer_dashboard, "WEBHOOK_PUBSUB_PONG_RECEIVED")
    echo(pid, ping_message_body)
  end

  def ping_message_body do
    Poison.encode!(%{
      topic: @channel,
      event: "heartbeat",
      ref: "ping",
      payload: ""
    })
  end
end
