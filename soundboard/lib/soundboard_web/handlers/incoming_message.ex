defmodule SoundboardWeb.IncomingMessageHandler do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [%{}])
  end

  def init([config]) do
    {:ok, %{}}
  end

  def handle_info({:message_sent, channel, user, message}, config) do
    process_message(channel, user, message)
    {:noreply, config}
  end

  def process_message(channel, user, message) do
    Logger.debug "message received on channel #{channel} from #{user}: #{message}"
    IO.puts "user: #{user}."

    if user == "malgasm" do
      SoundboardWeb.MessagingHelper.send_message("cmonBruh")
    end
  end
end
