defmodule SoundboardWeb.DiscordBot do
  use Nostrum.Consumer
  require Logger
  @guild_id 473969448491941888 #todo config this or some sh*t

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def create_message(channel, message_text) do
    Api.create_message(channel, content: message_text)
  end

  def create_tts_message(channel, message_text) do
    Api.create_message(channel, content: message_text, tts: true)
  end

  def get_current_guilds() do
    Api.get_current_user_guilds()
  end

  def get_guild_roles() do
    {:ok, roles} = Api.get_guild_roles(@guild_id)
    roles
  end

  def get_guild_members() do
    {:ok, members} = Api.list_guild_members(@guild_id, %{limit: 1000})
    members
  end

  def guild_member_ids() do
    Enum.map(get_guild_members, fn member ->
      member.user.id
    end)
  end

  def add_user_to_role(user_id, role_id) do
    {:ok} = Api.add_guild_member_role(@guild_id, user_id, role_id, "MalsHypeMan")
  end

  def add_user_to_chatgasm_champions(user_id) do
    role_id = 473993246348017664
    {:ok} = Api.add_guild_member_role(@guild_id, user_id, role_id, "MalsHypeMan")
  end

  def get_roles_by_name(name) do
    get_guild_roles
    |> Enum.filter(fn(role) -> role.name == name end)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    IO.inspect msg
    handle_message_by_user(msg.channel_id, msg.author.username, msg.content)
  end

  def handle_event({:HEARTBEAT_ACK, _msg, _ws_state}) do
    :noop
  end

  def handle_event({:PRESENCE_UPDATE, msg, _ws_state}) do
    {_, prev, cur} = msg

    if cur do
      add_user_to_chatgasm_champions(cur.user.id)
    end

    #todo: smelly

    cond do
      !cur ->
        IO.puts "Discord: received a presence update (cur missing)"
        IO.inspect(prev)
      !prev ->
        IO.puts "Discord: received a presence update (prev missing)"
        IO.inspect(cur)
      Map.has_key?(cur, :nick) && cur.nick != "" && cur.nick != nil ->
        IO.puts "Discord: received a presence update for #{cur.nick} (#{prev.status} -> #{cur.status})"
      Map.has_key?(cur, :user) && Map.has_key?(cur.user, :username) ->
        IO.puts "Discord: received a presence update for #{cur.user.username} (#{prev.status} -> #{cur.status})"
      Map.has_key?(cur, :user) ->
        IO.puts "Discord: received a presence update for user id #{cur.user.id} (#{prev.status} -> #{cur.status})"
    end
  end

  def handle_event({event_name, msg, _}) do
    Logger.debug(fn -> "Unhandled Discord event #{event_name}" end)
    Logger.info("#{inspect msg}")
  end


  def handle_message_by_user(_, "MalsHypeMan", message) do
    IO.puts "discarding message #{message} sent by MalsHypeMan"
    :ignore
  end

  def handle_message_by_user(channel, "malgasm", message) do
    if String.starts_with?(message, "updatestatus") do
      Api.update_status(:online, String.replace(message, "updatestatus", ""), 0, "https://www.twitch.tv/woke")
    end

    case message do
      "test" ->
        create_message(channel, SoundboardWeb.SevenDaysManager.test)
      "7d2dstatus" ->
        create_message(channel, SoundboardWeb.SevenDaysManager.status)
      "restart7d2d" ->
        create_message(channel, SoundboardWeb.SevenDaysManager.stop)
        create_message(channel, SoundboardWeb.SevenDaysManager.start)
      "backup7d2d" ->
        create_message(channel, SoundboardWeb.SevenDaysManager.backup)
      _ ->
        :noop
    end

    if String.starts_with?(message, "updatestatusstreaming") do
      cmd = String.replace(message, "updatestatusstreaming", "")
      cmds = String.split(cmd, ";")
      IO.puts("game: #{Enum.at(cmds, 1)} url: #{Enum.at(cmds, 0)}")
      Api.update_status(:online, Enum.at(cmds, 1), 1, Enum.at(cmds, 0))
    end
    handle_message_by_user(channel, "@malgasm", message)
  end

  def handle_message_by_user(channel, username, message) do
    IO.puts "handling message #{message} from user #{username}"
    case message do
      "uwu" ->
        create_tts_message(channel, "uwu")
      _ ->
        :ignore
    end

  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  # def handle_event(_event) do
  #   :noop
  # end
end
