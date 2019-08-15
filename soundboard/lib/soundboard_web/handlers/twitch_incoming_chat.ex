defmodule SoundboardWeb.TwitchIncomingChatHandler do
  use GenServer
  require Logger

  defmodule Config do
    defstruct server:  "irc.twitch.tv",
              port:    6667,
              pass:    Application.get_env(:soundboard, :twitch_oauth_key_chat_incoming),
              nick:    Application.get_env(:soundboard, :twitch_username_incoming),
              user:    Application.get_env(:soundboard, :twitch_username_incoming),
              name:    Application.get_env(:soundboard, :twitch_username_incoming),
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
    Logger.info "user joined #{channel} (incoming handler)"
    {:noreply, config}
  end
  def handle_info({:joined, channel, user_info}, config) do
    Logger.info "user #{user_info.nick} joined #{channel} (incoming handler /3)"
    {:noreply, config}
  end
  def handle_info({:parted, channel, user_info}, config) do
    Logger.info "user #{user_info.nick} left #{channel} (incoming handler /3)"
    {:noreply, config}
  end
  def handle_info({:parted, channel}, config) do
    Logger.info "user parted #{channel} (incoming handler)"
    {:noreply, config}
  end
  def handle_info({:names_list, channel, names_list}, config) do
    names = String.split(names_list, " ", trim: true)
            |> Enum.map(fn name -> " #{name}\n" end)
    Logger.info "Users logged in to #{channel}:\n#{names} (incoming handler)"
    {:noreply, config}
  end
  def handle_info({:received, msg, %SenderInfo{:nick => nick}, channel}, config) do
    Logger.info "#{nick} from #{channel}: #{msg} (incoming handler)"
    {:noreply, config}
  end

  def handle_info({:mentioned, msg, %SenderInfo{:nick => nick}, channel}, config) do
    Logger.warn "#{nick} mentioned you in #{channel}"
    case String.contains?(msg, "hi") do
      true ->
        reply = "Hi #{nick}!"
        Client.msg config.client, :privmsg, config.channel, reply
        Logger.info "Sent #{reply} to #{config.channel}"
      false ->
        :ok
    end
    {:noreply, config}
  end

  def handle_info({:unrecognized, msg, %ExIRC.Message{:args => args, :cmd => cmd}}, config) do
    arg = Enum.at(args, 0)
    Logger.warn "UNRECOGNIZED HANDLER!!!"
    IO.puts "cmd"
    IO.inspect cmd
    IO.puts "arg"
    IO.inspect arg
    handle_tagged_message(message_type_from_tagged_arg(arg), cmd, arg)
    {:noreply, config}
  end

  defp handle_tagged_message("CLEARCHAT", cmd, arg) do
    IO.puts "CLEARCHAT request received"
    #todo: issue request to suppress chat from user on client
  end

  defp handle_tagged_message("PRIVMSG", cmd, arg) do
    IO.puts "PRIVMSG GOGOGOG #{message_from_tagged_arg(arg)}"
    args = {
      :message_sent,
      channel_from_tagged_arg(arg),
      %{
        username: username_from_tagged_cmd(cmd),
        isMod: get_mod_status_from_cmd(cmd),
        isSub: get_sub_status_from_cmd(cmd),
        bits: get_bits_from_cmd(cmd)
      },
      message_from_tagged_arg(arg)
    }
    SoundboardWeb.ProcessHelper.send_process(SoundboardWeb.IncomingMessageHandler, args)
  end

  defp handle_tagged_message(_, cmd, arg) do
    IO.puts "unhandled tagged message"
    IO.inspect cmd
  end

  def handle_info({:received, msg, %SenderInfo{:nick => nick}}, config) do
    Logger.warn "#{nick}: #{msg}"
    reply = "Hi!"
    Client.msg config.client, :privmsg, nick, reply
    Logger.info "Sent #{reply} to #{nick}"
    {:noreply, config}
  end
  # Catch-all for messages you don't care about
  def handle_info(msg, config) do
    IO.inspect msg
    Logger.warn "CATCH-ALL !!!!!!! \n\n\n\n\n\n"
    {:noreply, config}
  end

  def cap_request(client, cap) do
    request = Client.cmd(client, ['CAP ', 'REQ ', cap])
    IO.puts "CAP REQUEST\n\n\n\n\n\n\n"
    IO.inspect request
    IO.inspect client
  end

  def request_twitch_capabilities(client) do
    # Request capabilities before joining the channel
    [
      ':twitch.tv/membership',
      ':twitch.tv/commands',
      ':twitch.tv/tags'
    ]
      |> Enum.each(fn (cap) -> cap_request(client, cap) end)

    client
  end

  def join(client, channels) when is_list(channels) do
    channels
      |> Enum.map(&join(client, &1))
    client
  end

  def join(client, channel) do
    Client.join(client, channel)
    Logger.debug "Joined channel: #{channel}"
  end

  defp message_from_tagged_arg_regex, do: ~r/PRIVMSG #\w+\s:(.*)$/

  defp channel_from_tagged_arg_regex, do: ~r/PRIVMSG #(\w+)\s:/

  defp username_from_tagged_cmd_regex, do: ~r/display-name=(\w+)[;$]/

  defp username_from_tagged_cmd(cmd), do: Regex.run(username_from_tagged_cmd_regex, cmd) |> parse_message_regex

  defp channel_from_tagged_arg(arg), do: Regex.run(channel_from_tagged_arg_regex, arg) |> parse_message_regex

  defp message_from_tagged_arg(arg), do: Regex.run(message_from_tagged_arg_regex, arg) |> parse_message_regex

  defp parse_message_regex(nil), do: nil
  defp parse_message_regex(result), do: Enum.at(result, 1)

  defp message_type_regex, do: ~r/tmi.twitch.tv\s(\w+?)\s/

  defp mod_status_check_1_from_cmd_regex, do: ~r/user-type=mod/

  defp mod_status_check_2_from_cmd_regex, do: ~r/mod=1;/

  defp sub_status_check_from_cmd_regex, do: ~r/subscriber=1;/

  defp bits_check_from_cmd_regex, do: ~r/bits=(\d+);/

  defp display_name_from_cmd_regex, do: ~r/subscriber=1;/

  defp get_mod_status_from_cmd(cmd) do
    Regex.run(mod_status_check_1_from_cmd_regex, cmd) != nil &&
      Regex.run(mod_status_check_2_from_cmd_regex, cmd) != nil
  end

  defp get_bits_from_cmd(cmd), do: Regex.run(bits_check_from_cmd_regex, cmd) |> parse_message_regex

  defp get_sub_status_from_cmd(cmd), do: Regex.run(sub_status_check_from_cmd_regex, cmd) != nil

  defp message_type_from_tagged_arg(arg), do: Regex.run(message_type_regex, arg) |> parse_message_regex

  def terminate(_, state) do
    # Quit the channel and close the underlying client connection when the process is terminating
    Client.quit state.client, "Goodbye, cruel world."
    Client.stop! state.client
    :ok
  end
end
