defmodule RustRcon do
  use WebSockex
  require Logger

  def start_link(opts \\ []) do
    WebSockex.start_link("ws://rust.malgasm.com:28016/azanpogo", __MODULE__, :fake_state, opts)
  end

  @spec echo(pid, String.t) :: :ok
  def echo(client, message) do
    Logger.info("Sending message: #{message}")
    WebSockex.send_frame(client, {:text, message})
  end

  def get_whitelist(client) do
    WebSockex.send_frame(client, {:text, message_body("oxide.show group whitelist")})
  end

  def authorize_user(client, user) do
    WebSockex.send_frame(client, {:text, message_body("oxide.usergroup add #{user} whitelist")})
  end

  def revoke_user_authorization(client, user) do
    WebSockex.send_frame(client, {:text, message_body("oxide.usergroup remove #{user} whitelist")})
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def handle_frame({:text, "Can you please reply yourself?" = msg}, :fake_state) do
    Logger.info("Received Message: #{msg}")
    msg = "Sure can!"
    Logger.info("Sending message: #{msg}")
    {:reply, {:text, msg}, :fake_state}
  end

  def handle_frame({:text, "Close the things!" = msg}, :fake_state) do
    Logger.info("Received Message: #{msg}")
    {:close, :fake_state}
  end

  def handle_frame({:text, %{"Message" => message}}, :fake_state) do
    Logger.info message
  end

  def handle_frame({:text, msg}, :fake_state) do
    Logger.info("Received Rust RCON Message: #{msg}")
    message = Jason.decode!(msg)["Message"]
    Logger.warn "message: #{message}"
    if String.starts_with?(message, "Group 'whitelist'") do
      if KV.Bucket.get(:steamid_discord_channel) do
        SoundboardWeb.DiscordBot.create_message(KV.Bucket.get(:steamid_discord_channel), message)
      end
    else
      # Logger.debug message
    end

    if String.contains?(msg, "added to group: whitelist") do
      Logger.error "ADD"
      SoundboardWeb.DiscordBot.create_message(KV.Bucket.get(:steamid_discord_channel), message)
    end

    if String.contains?(msg, "removed from group 'whitelist") do
      Logger.error "REMOVE"
      SoundboardWeb.DiscordBot.create_message(KV.Bucket.get(:steamid_discord_channel), message)
    end

    {:ok, :fake_state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect reason}")
    {:ok, state}
  end
  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  defp message_body(message_text) do
    Jason.encode!(%{"Identifier"=>12345,"Message"=>message_text,"Name"=>"streamerdashboard"})
  end
end
