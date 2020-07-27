defmodule SoundboardWeb.PeriodicMessage do
  use GenServer
  require Logger

  def load_periodic_messages do
    {:ok, messages} = SoundboardWeb.Filesystem.read_file("messages/periodic_messages.yml")
    |> YamlElixir.read_from_string

    messages
  end

  def pick_a_message() do
    Enum.random(load_periodic_messages()["messages"])
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [%{}])
  end

  def init([config]) do
    Logger.info("starting PeriodicMessage service")
    delay_then_say()
    {:ok, config}
  end

  defp random_delay() do
    :rand.uniform(1200) * 1000
  end

  defp delay_then_say() do
    delay = random_delay
    Logger.info("waiting #{delay}ms")
    Process.send_after(self(), :say_something, delay)
  end

  def handle_info(:say_something, state) do
    Logger.info("saying something")
    SoundboardWeb.MessagingHelper.send_twitch_chat_message(pick_a_message())
    delay_then_say()
    {:noreply, state}
  end
end
