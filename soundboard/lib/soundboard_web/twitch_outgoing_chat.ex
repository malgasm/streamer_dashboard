defmodule SoundboardWeb.TwitchOutgoingChatHandler do
  use GenServer
  require Logger
  import SoundboardWeb.TwitchConnectionHandler


  alias ExIRC.Client
  alias ExIRC.SenderInfo

  def start_link(_) do
    config = %{
      host:  Application.get_env(:soundboard, :twitch_outgoing_server) || "irc.twitch.tv",
      port:    6667,
      pass:    Application.get_env(:soundboard, :twitch_outgoing_pass),
      nick:    Application.get_env(:soundboard, :twitch_outgoing_nick),
      user:    Application.get_env(:soundboard, :twitch_outgoing_user),
      name:    Application.get_env(:soundboard, :twitch_outgoing_name),
      channel: Application.get_env(:soundboard, :twitch_outgoing_channel),
      client:  nil
    }
    GenServer.start_link(__MODULE__, [config])
  end

  def init([config]) do
    # Start the client and handler processes, the ExIRC supervisor is automatically started when your app runs
    {:ok, client}  = ExIRC.start_link!()

    # Register the event handler with ExIRC
    Client.add_handler client, self()

    # Connect and logon to a server, join a channel and send a simple message
    Logger.debug "(outgoing) Connecting to #{config.host}:#{config.port}"
    Client.connect! client, config.host, config.port

    {:ok, Map.put(config, :client, client)}
  end

  def handle_call({:send_message, message}, _from, config) do
    Logger.info "sending message #{message} to channel #{config.channel}"
    Client.msg config.client, :privmsg, config.channel, message
    {:reply, message, config}
  end

  def handle_info({:connected, server, port}, config) do
    Logger.debug "Connected to #{server}:#{port}"
    Logger.debug "(outgoing) Logging to #{server}:#{port} as #{config.nick}.."
    Client.logon config.client, config.pass, config.nick, config.user, config.name
    {:noreply, config}
  end
  def handle_info(:logged_in, config) do
    Logger.debug "Logged in to #{config.host}:#{config.port}!!!!!!!!!!!!!!!!!!!!!!!!"
    Logger.debug "Joining #{config.channel}.................................................."
    request_twitch_capabilities(config.client)
		|> join(config.channel)
    # Client.join config.client, config.channel
    {:noreply, config}
  end
  def handle_info({:login_failed, :nick_in_use}, config) do
    nick = Enum.map(1..8, fn x -> Enum.random('abcdefghijklmnopqrstuvwxyz') end)
    Client.nick config.client, to_string(nick)
    {:noreply, config}
  end
  def handle_info(:disconnected, config) do
    Logger.debug "Disconnected from #{config.host}:#{config.port}"
    {:stop, :normal, config}
  end
  def handle_info({:joined, channel}, config) do
    Logger.debug "Joined #{channel}"
    # SoundboardWeb.MessagingHelper.send_twitch_chat_message("cmonBruh")
    {:noreply, config}
  end
  def handle_info({:names_list, channel, names_list}, config) do
    names = String.split(names_list, " ", trim: true)
            |> Enum.map(fn name -> " #{name}\n" end)
    Logger.info "Users logged in to #{channel}:\n#{names}"
    {:noreply, config}
  end

  def handle_info({:received, msg, %SenderInfo{:nick => nick}, channel}, config) do
    # message received in chat
    # Logger.info "#{nick} from #{channel}: #{msg} (outgoing)"
    {:noreply, config}
  end

  def handle_info(:enable_emoteonly, config) do
    Logger.info("Twitch Outgoing Chat Handler: Enabling emote-only mode")
    Client.msg config.client, :privmsg, config.channel, "/emoteonly"
    {:noreply, config}
  end

  def handle_info(:disable_emoteonly, config) do
    Logger.info("Twitch Outgoing Chat Handler: turning emote-only mode off.")
    Client.msg config.client, :privmsg, config.channel, "/emoteonlyoff"
    {:noreply, config}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, config) do
    {:noreply, config}
  end

  def request_twitch_capabilities(client) do
    # Request capabilities before joining the channel
    [
      # ':twitch.tv/membership',
      ':twitch.tv/commands'
      # ':twitch.tv/tags'
    ]
      |> Enum.each(fn (cap) -> cap_request(client, cap) end)

    client
  end

end
