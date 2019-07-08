defmodule SoundboardWeb.MessagingHelper do
  require Logger
  def send_message(message) do
    Logger.debug "sent message #{message}"
    SoundboardWeb.ProcessHelper.call_process(SoundboardWeb.TwitchHandler, {:send_message, message})
  end
end
