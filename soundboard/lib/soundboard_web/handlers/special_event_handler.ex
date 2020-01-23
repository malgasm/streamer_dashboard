defmodule SoundboardWeb.SpecialEventHandler do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [%{}])
  end

  def init([config]) do
    {:ok, %{}}
  end

  def handle_info({:raid, params}, config) do
    broadcast_new_special_event(:raid, params)
    {:noreply, config}
  end
  def handle_info({:resub, params}, config) do
    IO.puts "YOOO WE GOT A RESUB!!!!!!! "

    broadcast_new_special_event(:resub, params)
#   gift_sub_recipient: nil,
#   sub_months: "6",
#   sub_streak: "6",
#   sub_tier: "1",
#   username:

    handle_resub(params)
    {:noreply, config}
  end

  def handle_info({:anonsubgift, params}, config) do
    IO.puts "YOOO WE GOT AN ANON GIFT SUB!!!!!!! "
    broadcast_new_special_event(:subgift, params)

    handle_gift_sub(params)
    {:noreply, config}
  end

  def handle_info({:subgift, params}, config) do
    IO.puts "YOOO WE GOT A GIFT SUB!!!!!!! "
    broadcast_new_special_event(:subgift, params)
    handle_gift_sub(params)

    {:noreply, config}
  end

  def handle_info({:sub, params}, config) do
    IO.puts "YOOO WE GOT A SUB!!!!!!! "
    broadcast_new_special_event(:sub, params)
    handle_sub(params)

    {:noreply, config}
  end

  def handle_info({:submysterygift, params}, config) do
    IO.puts "YOOO WE GOT MULTIPLE GIFT SUBS!!!!!!! "
    broadcast_new_special_event(:multiple_gift_subs, params)
    handle_multiple_gift_subs(params)

    {:noreply, config}
  end

  def handle_info({:channel_points_redemption, params}, config) do
    IO.puts "SEH: #{params.username} redeemed #{params.redemption}"
    SoundboardWeb.ChannelPointsRedemptions.handle_redemption(params.username, params.redemption, params.entered_text)
    {:noreply, config}
  end

  def handle_info({message_id, params}, config) do
    IO.puts "UNHANDLED SPECIAL EVENT MESSAGE TYPE: #{message_id}"
    broadcast_new_special_event(:unknown, params)
    {:noreply, config}
  end

  defp handle_sub(params) do
    send_message "YOOO #{params.username}!! Welcome to the MalPals!!!! malgasLove malgasLove malgasLove malgasLove malgasLove malgasGrin"
  end

  defp handle_multiple_gift_subs(params) do
    send_message "HOLY SH*T!! #{params.username} just gifted #{params.gift_sub_quantity} subs!!! malgasWoot malgasLove malgasWoot malgasLove malgasWoot malgasLove malgasWoot malgasLove malgasWoot malgasLove malgasWoot malgasLove malgasWoot malgasLove malgasWoot malgasLove malgasWoot malgasLove Thank you #{params.username}!!!"
    play_airhorn(String.to_integer(params.gift_sub_quantity))
  end

  defp play_airhorn(quantity = 1) do
    IO.puts "playing airhorn #{quantity}"
    if quantity > 0 do
      SoundboardWeb.MessagingHelper.broadcast_new_play_sound_event("airhorn")
      :timer.sleep(125)
      play_airhorn(quantity - 1)
    end
  end

  defp handle_gift_sub(params) do
    message = if params.username do
      "Thank you #{params.username} for gifting a sub to #{params.gift_sub_recipient}!!! malgasLove malgasLove malgasLove malgasLove malgasLove malgasGrin"
    else
      "Thank you you lovely anonymous person for gifting a sub to #{params.gift_sub_recipient}!!! malgasLove malgasLove malgasLove malgasLove malgasLove malgasGrin"
    end
    send_message(message)
    #todo: special messages for tier 2 & 3 subs
    #todo: sounds
  end

  defp handle_resub(params) do
    send_message "Thank you #{params.username} for continuing your sub for #{params.sub_months} friggin months!!! Look at you go with that #{params.sub_streak} month streak malgasLove malgasLove malgasLove malgasLove malgasLove malgasGrin"
  end

  defp broadcast_new_special_event(type, params) do
    SoundboardWeb.MessagingHelper.broadcast_new_special_event(type, params)
  end

  defp send_message(msg) do
    SoundboardWeb.ProcessHelper.call_process(SoundboardWeb.TwitchOutgoingChatHandler, {:send_message, msg})
  end
end
