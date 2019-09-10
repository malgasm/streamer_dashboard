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
    {:noreply, config}
  end
  def handle_info({:resub, params}, config) do
    IO.puts "YOOO WE GOT A RESUB!!!!!!! "

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

    handle_gift_sub(params)
    {:noreply, config}
  end

  def handle_info({:subgift, params}, config) do
    IO.puts "YOOO WE GOT A GIFT SUB!!!!!!! "

    handle_gift_sub(params)
    {:noreply, config}
  end

  def handle_info({:sub, params}, config) do
    IO.puts "YOOO WE GOT A SUB!!!!!!! "
    handle_sub(params)
    {:noreply, config}
  end

  def handle_info({message_id, params}, config) do
    IO.puts "UNHANDLED SPECIAL EVENT MESSAGE TYPE: #{message_id}"
    {:noreply, config}
  end

  def handle_sub(params) do
    send_message "YOOO #{params.username}!! Welcome to the MalPals!!!! malgasLove malgasLove malgasLove malgasLove malgasLove malgasGrin"
  end

  def handle_gift_sub(params) do
    message = if params.username do
      "Thank you #{params.username} for gifting a sub to #{params.gift_sub_recipient}!!! malgasLove malgasLove malgasLove malgasLove malgasLove malgasGrin"
    else
      "Thank you you lovely anonymous person for gifting a sub to #{params.gift_sub_recipient}!!! malgasLove malgasLove malgasLove malgasLove malgasLove malgasGrin"
    end
    send_message(message)
    #todo: special messages for tier 2 & 3 subs
    #todo: sounds
  end

  def handle_resub(params) do
    send_message "Thank you #{params.username} for continuing your sub for #{params.sub_months} friggin months!!! Look at you go with that #{params.sub_streak} month streak malgasLove malgasLove malgasLove malgasLove malgasLove malgasGrin"
  end

  defp send_message(msg) do
    SoundboardWeb.ProcessHelper.call_process(SoundboardWeb.TwitchOutgoingChatHandler, {:send_message, msg})
  end
end
