defmodule SoundboardWeb.TwitchOutgoingChatHandler do
  use GenServer
  require Logger
  import SoundboardWeb.TwitchConnectionHandler

  defmodule Config do
    defstruct server:  "irc.twitch.tv",
              port:    6667,
              pass:    Application.get_env(:soundboard, :twitch_oauth_key_chat_outgoing),
              nick:    Application.get_env(:soundboard, :twitch_username_outgoing),
              user:    Application.get_env(:soundboard, :twitch_username_outgoing),
              name:    Application.get_env(:soundboard, :twitch_username_outgoing),
              channel: Application.get_env(:soundboard, :twitch_channel),
              client:  nil

    def from_params(params) when is_map(params) do
      Enum.reduce(params, %Config{}, fn {k, v}, acc ->
        case Map.has_key?(acc, k) do
          true  -> Map.put(acc, k, v)
          false -> acc
        end
      end)
    end
  end

  alias ExIRC.Client
  alias ExIRC.SenderInfo

  def start_link() do
    config = %Config{}
    GenServer.start_link(__MODULE__, [config])
  end

  def init([config]) do
    # Start the client and handler processes, the ExIRC supervisor is automatically started when your app runs
    {:ok, client}  = ExIRC.start_link!()

    # Register the event handler with ExIRC
    Client.add_handler client, self()

    # Connect and logon to a server, join a channel and send a simple message
    Logger.debug "Connecting to #{config.server}:#{config.port}"
    Client.connect! client, config.server, config.port

    {:ok, %Config{config | :client => client}}
  end

  def handle_call({:send_message, message}, _from, config) do
    Logger.info "sending message #{message} to channel #{config.channel}"
    Client.msg config.client, :privmsg, config.channel, message
    {:reply, message, config}
  end

  def handle_info({:connected, server, port}, config) do
    Logger.debug "Connected to #{server}:#{port}"
    Logger.debug "Logging to #{server}:#{port} as #{config.nick}.."
    Client.logon config.client, config.pass, config.nick, config.user, config.name
    {:noreply, config}
  end
  def handle_info(:logged_in, config) do
    Logger.debug "Logged in to #{config.server}:#{config.port}!!!!!!!!!!!!!!!!!!!!!!!!"
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
    Logger.debug "Disconnected from #{config.server}:#{config.port}"
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
    Logger.info "#{nick} from #{channel}: #{msg} (outgoing)"
    {:noreply, config}
  end

  def handle_info({:mentioned, msg, %SenderInfo{:nick => nick}, channel}, config) do
    Logger.warn "#{nick} mentioned you in #{channel}"
    case String.contains?(msg, "hi") do
      true ->
        reply = "#{nick} malgasLove malgasLove malgasLove malgasLove malgasLove"
        Client.msg config.client, :privmsg, config.channel, reply
        Logger.info "Sent #{reply} to #{config.channel}"
      false ->
        :ok
    end
    {:noreply, config}
  end
  def handle_info({:received, msg, %SenderInfo{:nick => nick}}, config) do
    Logger.warn "#{nick}: #{msg}"
    reply = "Hi!"
    Client.msg config.client, :privmsg, nick, reply
    Logger.info "Sent #{reply} to #{nick}"
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
