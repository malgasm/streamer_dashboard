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

  defp handle_tagged_message("CLEARCHAT", cmd, arg) do
    IO.puts "CLEARCHAT request received"
  end

  defp handle_tagged_message("PRIVMSG", cmd, arg) do
    SoundboardWeb.ProcessHelper.send_process(
      SoundboardWeb.IncomingMessageHandler,
      prepare_message_from_irc(arg, cmd)
    )

    message = message_from_tagged_arg(arg)
    # IO.puts "EMOTES\n\n\n\n\n\n"
    #

    Logger.info "(incoming chat) Received message #{inspect message} from user #{username_from_cmd(cmd)}"

    SoundboardWeb.AnimationCommandsHelper.animate_emotes(emote_ids_from_cmd(cmd))

    if message == "testvideo" && username_from_cmd(cmd) == "malgasm"  do

      IO.puts "TESTVIDEO\n\n\n\n"

      SoundboardWeb.MessagingHelper.broadcast_new_play_video_event("8TGUnriw9k4")
    end

    if message == "simulatesub" && username_from_cmd(cmd) == "malgasm"  do
      IO.puts "SIMULATESUB\n\n\n\n"
      cmdz = "@badge-info=subscriber/6;badges=moderator/1,subscriber/6,overwatch-league-insider_2019A/1;color=#FF0000;display-name=Shroud;emotes=;flags=;id=1399c486-1376-48f1-8489-f313af16d507;login=Shroud;mod=1;msg-id=sub;msg-param-cumulative-months=6;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=6;msg-param-sub-plan-name=Channel\\sSubscription\\s(malgasm);msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=Shroud\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s6\\smonths,\\scurrently\\son\\sa\\s6\\smonth\\sstreak!;tmi-sent-ts=1568082484294;user-id=129228929;user-type=mod"
      # IO.inspect prepare_special_event_args("", cmdz)

      SoundboardWeb.ProcessHelper.send_process(
        SoundboardWeb.SpecialEventHandler,
        prepare_special_event_args("", cmdz)
      )
    end
    if message == "simulateresub" && username_from_cmd(cmd) == "malgasm"  do
      IO.puts "SIMULATERESUB\n\n\n\n"
      cmdz = "@badge-info=subscriber/6;badges=moderator/1,subscriber/6,overwatch-league-insider_2019A/1;color=#FF0000;display-name=Shroud;emotes=;flags=;id=1399c486-1376-48f1-8489-f313af16d507;login=Shroud;mod=1;msg-id=resub;msg-param-cumulative-months=6;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=6;msg-param-sub-plan-name=Channel\\sSubscription\\s(malgasm);msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=Shroud\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s6\\smonths,\\scurrently\\son\\sa\\s6\\smonth\\sstreak!;tmi-sent-ts=1568082484294;user-id=129228929;user-type=mod"
      IO.inspect prepare_special_event_args("", cmdz)

      SoundboardWeb.ProcessHelper.send_process(
        SoundboardWeb.SpecialEventHandler,
        prepare_special_event_args("", cmdz)
      )
    end

    if message == "simulateresubnostreak" && username_from_cmd(cmd) == "malgasm"  do
      IO.puts "SIMULATERESUB\n\n\n\n"
      cmdz = "@badge-info=subscriber/6;badges=moderator/1,subscriber/6,overwatch-league-insider_2019A/1;color=#FF0000;display-name=Shroud;emotes=;flags=;id=1399c486-1376-48f1-8489-f313af16d507;login=Shroud;mod=1;msg-id=resub;msg-param-cumulative-months=6;msg-param-months=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(malgasm);msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=Shroud\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s6\\smonths,\\scurrently\\son\\sa\\s6\\smonth\\sstreak!;tmi-sent-ts=1568082484294;user-id=129228929;user-type=mod"
      IO.inspect prepare_special_event_args("", cmdz)

      SoundboardWeb.ProcessHelper.send_process(
        SoundboardWeb.SpecialEventHandler,
        prepare_special_event_args("", cmdz)
      )
    end

    if message == "simulatemultiplegiftsubs" && username_from_cmd(cmd) == "malgasm"  do
      IO.puts "SIMULATE MULTIPLE GIFT SUBS\n\n\n\n\n\n"
      cmdz = "@badge-info=subscriber/6;badges=moderator/1,subscriber/6,overwatch-league-insider_2019A/1;color=#FF0000;display-name=Shroud;emotes=;flags=;id=75cf0038-ab1e-4842-82ce-b35f214f8eca;login=Shroud;mod=1;msg-id=submysterygift;msg-param-mass-gift-count=5;msg-param-origin-id=69\s46\s38\sfc\s9b\see\s7f\sb5\s3d\s1b\s81\s8d\s58\s91\s02\s21\s59\s86\s1b\s5d;msg-param-sender-count=45;msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=Shroud\sis\sgifting\s5\sTier\s1\sSubs\sto\smalgasm's\scommunity!\sThey've\sgifted\sa\stotal\sof\s45\sin\sthe\schannel!;tmi-sent-ts=1568090502470;user-id=129228929;user-type=mod"

      SoundboardWeb.ProcessHelper.send_process(
        SoundboardWeb.SpecialEventHandler,
        prepare_special_event_args("", cmdz)
      )
    end

    if message == "simulategiftsub" && username_from_cmd(cmd) == "malgasm" do
      IO.puts "SIMULATEGIFTSUB\n\n\n\n"
      cmdz = "@badge-info=subscriber/12;badges=broadcaster/1,subscriber/12,sub-gifter/1;color=#22DD13;display-name=malgasm;emotes=;flags=;id=281ce9a4-e4eb-4a63-a58e-8503b33a1b69;login=malgasm;mod=0;msg-id=subgift;msg-param-months=1;msg-param-origin-id=da\\s39\\sa3\\see\\s5e\\s6b\\s4b\\s0d\\s32\\s55\\sbf\\sef\\s95\\s60\\s18\\s90\\saf\\sd8\\s07\\s09;msg-param-recipient-display-name=phnxdwn_n;msg-param-recipient-id=81307341;msg-param-recipient-user-name=phnxdwn_n;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(malgasm);msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=malgasm\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sphnxdwn_n!;tmi-sent-ts=1568084845220;user-id=158826258;user-type="
      IO.inspect prepare_special_event_args("", cmdz)

      SoundboardWeb.ProcessHelper.send_process(
        SoundboardWeb.SpecialEventHandler,
        prepare_special_event_args("", cmdz)
      )
    end
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

  defp handle_tagged_message(_, cmd, arg) do
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
