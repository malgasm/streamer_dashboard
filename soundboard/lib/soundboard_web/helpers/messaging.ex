defmodule SoundboardWeb.MessagingHelper do
  require Logger

  def send_twitch_chat_message(message) do
    Logger.debug "sent message #{message}"
    SoundboardWeb.ProcessHelper.call_process(SoundboardWeb.TwitchOutgoingChatHandler, {:send_message, message})
  end
  #todo
  #- test
  #- use only type and params as top-level keys
  #- dry

  def broadcast_new_special_event(type, params) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: type,
        params: params
      }
    )
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

  def broadcast_brb_direction_change(direction) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: "change-brb-direction",
        value: direction
      }
    )
  end

  def broadcast_new_animation_event(emote, count) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: "animate-overlay",
        value: %{
          emote: emote,
          count: count
        }
      }
    )
  end

  def broadcast_new_play_sound_event(sound) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: "play-sound",
        value: %{
          sound: SoundboardWeb.Sounds.get_sound_relative_path_for_web(sound),
          volume: 1 #todo: default volume per sound
        }
      }
    )
  end

  def broadcast_new_play_sound_event(sound, volume) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: "play-sound",
        value: %{
          sound: SoundboardWeb.Sounds.get_sound_relative_path_for_web(sound),
          volume: volume
        }
      }
    )
  end

  def broadcast_new_play_video_event(video) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: "play-video",
        value: %{
          video: video
        }
      }
    )
  end

  def broadcast_new_channel_points_redemption_event(user, redemption) do
    SoundboardWeb.Endpoint.broadcast("stream_session:lobby", "stream_action",
      %{
        type: "channel-points-redemption",
        params: %{
          name: redemption,
          user: user
        }
      }
    )
  end
end
