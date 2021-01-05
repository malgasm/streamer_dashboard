defmodule SoundboardWeb.TwitchIncomingChatHandler do
  use GenServer
  require Logger
  import SoundboardWeb.TwitchConnectionHandler
  import SoundboardWeb.TwitchTagDecoder

  alias ExIRC.Client
  alias ExIRC.SenderInfo

  def start_link(_) do
    config = %{
      host:  Application.get_env(:soundboard, :twitch_incoming_server) || "irc.twitch.tv",
      port:    6667,
      pass:    Application.get_env(:soundboard, :twitch_incoming_pass),
      nick:    Application.get_env(:soundboard, :twitch_incoming_nick),
      user:    Application.get_env(:soundboard, :twitch_incoming_user),
      name:    Application.get_env(:soundboard, :twitch_incoming_name),
      channel: Application.get_env(:soundboard, :twitch_incoming_channel),
      client:  nil
    }
    IO.puts "incoming start #{inspect config}"
    GenServer.start_link(__MODULE__, [config])
  end

  def init([config]) do
    # Start the client and handler processes, the ExIRC supervisor is automatically started when your app runs
    {:ok, client}  = ExIRC.start_link!()

    # Register the event handler with ExIRC
    Client.add_handler client, self()

    # Connect and logon to a server, join a channel and send a simple message
    Logger.debug "(incoming) Connecting to #{config.host}:#{config.port} [#{inspect @config}]"
    Client.connect! client, config.host, config.port

    {:ok, Map.put(config, :client, client)}
  end

  def handle_call({:send_message, message}, _from, config) do
    Logger.info "sending message #{message} to channel #{config}"
    Client.msg config.client, :privmsg, config.channel, message
    {:reply, message, config}
  end

  def handle_info({:connected, server, port}, config) do
    Logger.debug "Connected to #{server}:#{port}"
    Logger.debug "(incoming) Logging to #{server}:#{port} as #{config.nick}(#{config.name})..."
    Client.logon config.client, config.pass, config.nick, config.user, config.name
    {:noreply, config}
  end
  def handle_info(:logged_in, config) do
    Logger.debug "Logged in to #{config.host}:#{config.port}!!!!!!!!!!!!!!!!!!!!!!!!"
    Logger.debug "Joining #{config.channel}.................................................."
    request_twitch_capabilities(config.client)
		|> join(config.channel)
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
  def handle_info({:joined, channel, user_info}, config) do
    Soundboard.SoundboardWeb.StreamEvents.create_event(user_info.nick, "USER_JOINED", %{})
    {:noreply, config}
  end
  def handle_info({:parted, channel, user_info}, config) do
    Soundboard.SoundboardWeb.StreamEvents.create_event(user_info.nick, "USER_LEFT", %{})
    {:noreply, config}
  end

  def handle_info({:parted, channel}, config) do
    Logger.error "user parted #{channel} (incoming handler /2)"
    {:noreply, config}
  end
  def handle_info({:names_list, channel, names_list}, config) do
    names = String.split(names_list, " ", trim: true)
            |> Enum.map(fn name ->
              Soundboard.SoundboardWeb.StreamEvents.create_event(name, "USER_JOINED", %{})
              " #{name}\n"
            end)
    {:noreply, config}
  end

  def handle_info({:unrecognized, "CAP", msg}, config) do
    IO.puts "Capability request sent to twitch.\n"
    {:noreply, config}
  end

  def handle_info({:unrecognized, msg, %ExIRC.Message{:args => args, :cmd => cmd}}, config) do
    arg = Enum.at(args, 0)
    handle_tagged_message(message_type_from_tagged_arg(arg), cmd, arg)
    {:noreply, config}
  end

  def handle_tagged_message("CLEARCHAT", cmd, arg) do
    IO.puts "CLEARCHAT request received"
  end

  #todo: figure out a better way to test this and make it private again
  def handle_tagged_message("PRIVMSG", cmd, arg) do
    SoundboardWeb.ProcessHelper.send_process(
      SoundboardWeb.IncomingMessageHandler,
      prepare_message_from_irc(arg, cmd)
    )

    message = message_from_tagged_arg(arg)
    # IO.puts "EMOTES\n\n\n\n\n\n"

    Logger.info "(incoming chat) PRIVMSG #{inspect arg} #{inspect cmd}"
    Logger.info "(incoming chat) Received message #{inspect message} from user #{username_from_cmd(cmd)}"

    SoundboardWeb.AnimationCommandsHelper.animate_emotes(emote_ids_from_cmd(cmd))

    if message == "testvideo" && username_from_cmd(cmd) == "malgasm"  do

      IO.puts "TESTVIDEO\n\n\n\n"

      SoundboardWeb.MessagingHelper.broadcast_new_play_video_event("8TGUnriw9k4")
    end
  end

  def handle_tagged_message(_, cmd, arg) do
    IO.puts "unhandled tagged message"

    # IO.puts "parsed tags"
    # IO.inspect parse_tags(cmd)
    # IO.puts "arg"
    # IO.inspect arg

    if msg_id_from_cmd(cmd) do
      SoundboardWeb.ProcessHelper.send_process(
        SoundboardWeb.SpecialEventHandler,
        prepare_special_event_args(arg, cmd)
      )
    end

    IO.inspect cmd
  end

  defp prepare_message_from_irc(arg, cmd) do
    {
      :message_sent,
      channel_from_tagged_arg(arg),
      %{
        username: username_from_cmd(cmd),
        isMod: mod_status_from_cmd(cmd),
        isSub: sub_status_from_cmd(cmd),
        bits: bits_from_cmd(cmd),
        emotes: emotes_from_cmd(cmd)
      },
      message_from_tagged_arg(arg)
    }
  end

  defp prepare_special_event_args(arg, cmd) do
    IO.inspect parse_tags(cmd)

    {
      String.to_atom(msg_id_from_cmd(cmd)),
      %{
        username: display_name_from_cmd(cmd),
        bits: bits_from_cmd(cmd),
        sub_streak: sub_streak_from_cmd(cmd),
        gift_sub_recipient: gift_sub_recipient_from_cmd(cmd),
        sub_months: sub_months_from_cmd(cmd),
        sub_tier: sub_tier_from_cmd(cmd),
        gift_sub_quantity: gift_sub_quantity_from_cmd(cmd)
      }
    }
  end

  def handle_info(msg, config) do
    IO.inspect msg
    Logger.warn "CATCH-ALL !!!!!!! \n\n\n\n\n\n"
    {:noreply, config}
  end


  # Request capabilities before joining the channel
  def request_twitch_capabilities(client) do
    [
      ':twitch.tv/membership',
      ':twitch.tv/commands',
      ':twitch.tv/tags'
    ]
      |> Enum.each(fn (cap) -> cap_request(client, cap) end)

    client
  end

  defp emote_ids(""), do: nil
  defp emote_ids(%{}), do: nil
  defp emote_ids(emotes) do
    String.split(emotes, "\/")
    |> Enum.map(fn emote_string ->
      [id, occurrences] = String.split(emote_string, ":")
      %{
        id: id,
        count: String.split(occurrences, ",") |> Kernel.length
      }
    end)
  end

  #methods for parsing arg

  defp message_from_tagged_arg_regex, do: ~r/PRIVMSG #\w+\s:(.*)$/

  defp channel_from_tagged_arg_regex, do: ~r/PRIVMSG #(\w+)\s:/

  defp channel_from_tagged_arg(arg), do: Regex.run(channel_from_tagged_arg_regex, arg) |> parse_message_regex

  defp message_from_tagged_arg(arg), do: Regex.run(message_from_tagged_arg_regex, arg) |> parse_message_regex

  defp parse_message_regex(nil), do: nil

  defp parse_message_regex(result), do: Enum.at(result, 1) |> String.trim()

  defp message_type_regex, do: ~r/tmi.twitch.tv\s(\w+?)\s/

  defp message_type_from_tagged_arg(arg), do: Regex.run(message_type_regex, arg) |> parse_message_regex

  #methods for parsing cmd

  defp display_name_from_cmd(cmd), do: parse_tags(cmd)["display-name"]

  defp username_from_cmd(cmd), do: display_name_from_cmd(cmd)

  defp emotes_from_cmd(cmd), do: parse_tags(cmd)["emotes"]

  defp emote_ids_from_cmd(cmd), do: parse_tags(cmd)["emotes"] |> emote_ids

  defp mod_status_from_cmd(cmd), do: parse_tags(cmd)["mod"] == "1"

  defp sub_status_from_cmd(cmd), do: parse_tags(cmd)["subscriber"] == "1"

  defp msg_id_from_cmd(cmd), do: parse_tags(cmd)["msg-id"]

  defp username_from_cmd(cmd), do: parse_tags(cmd)["display-name"] |> String.downcase

  defp bits_from_cmd(cmd), do: parse_tags(cmd)["bits"]

  def gift_sub_recipient_from_cmd(cmd), do: parse_tags(cmd)["msg-param-recipient-display-name"]

  def sub_tier_from_cmd(cmd), do: parse_tags(cmd)["msg-param-sub-plan"]

  def gift_sub_quantity_from_cmd(cmd), do: parse_tags(cmd)["msg-param-mass-gift-count"]

  def sub_months_from_cmd(cmd) do
    parse_tags(cmd)["msg-param-cumulative-months"] || parse_tags(cmd)["msg-param-months"]
  end

  def sub_streak_from_cmd(cmd), do: parse_tags(cmd)["msg-param-streak-months"]
end
