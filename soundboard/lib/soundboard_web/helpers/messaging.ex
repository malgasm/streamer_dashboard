defmodule SoundboardWeb.MessagingHelper do
  require Logger

  def send_twitch_chat_message(message) do
    Logger.debug "sent message #{message}"
    SoundboardWeb.ProcessHelper.call_process(SoundboardWeb.TwitchOutgoingChatHandler, {:send_message, message})
  end

  def broadcast_new_twitch_message(channel, user, message) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: "message",
        user: user,
        channel: channel,
        value: message
      }
    )
  end

  def broadcast_new_play_sound_event(sound) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: "play-sound",
        value: SoundboardWeb.Sounds.get_sound_relative_path_for_web(sound)
      }
    )
  end
end
