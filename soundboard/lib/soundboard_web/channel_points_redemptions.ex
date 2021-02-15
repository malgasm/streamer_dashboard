defmodule SoundboardWeb.ChannelPointsRedemptions do
  require Logger
  @emote_only_five_second_delay 5 * 1000
  @emote_only_one_minute_delay 60 * 1000
  @emote_only_five_minute_delay 5 * 60 * 1000
  @redemptions %{
  }

  def handle_redemption(user, redemption, entered_text) do
    SoundboardWeb.MessagingHelper.broadcast_new_channel_points_redemption_event(user, redemption)

    case redemption do
      "grinGasm" ->
        SoundboardWeb.MessagingHelper.broadcast_new_animation_event("grin", 50)
      "heartGasm" ->
        SoundboardWeb.MessagingHelper.broadcast_new_animation_event("love", 50)
      "Emote-Only for Five Seconds" ->
        send(outgoing_chat_service(), :enable_emoteonly)
        Process.send_after(outgoing_chat_service(), :disable_emoteonly, @emote_only_five_second_delay)
      "Emote-Only for a Minute" ->
        send(outgoing_chat_service(), :enable_emoteonly)
        Process.send_after(outgoing_chat_service(), :disable_emoteonly, @emote_only_one_minute_delay)
      "Emote-Only for Five Minutes" ->
        send(outgoing_chat_service(), :enable_emoteonly)
        Process.send_after(outgoing_chat_service(), :disable_emoteonly, @emote_only_five_minute_delay)
      "Play a Youtube Video" ->
        SoundboardWeb.MessagingHelper.broadcast_new_play_video_event(entered_text)
      "AcrizeLights™" ->
        SoundboardWeb.ProcessHelper.send_process(SoundboardWeb.Hue, {:set_color, entered_text})
      "Turn off the Camera" ->
        SoundboardWeb.ObsWebsocket.hide_camera(obs_websocket_service())
      "Turn on the Camera" ->
        SoundboardWeb.ObsWebsocket.show_camera(obs_websocket_service())
      "Move the Camera" ->
        #todo: split
        [x, y] = if String.contains?(entered_text, ",") do
          String.split(entered_text, ",")
        else
          String.split(entered_text, " ")
        end

        SoundboardWeb.ObsWebsocket.move_camera(obs_websocket_service(), sanitize_coord(x), sanitize_coord(y))
      _ ->
        Logger.debug "Unhandled redemption #{inspect redemption} from user #{user}"
    end
  end

  defp sanitize_coord(coord) do
    String.trim(coord)
    |> String.to_integer
  end

  defp outgoing_chat_service(), do: SoundboardWeb.ProcessHelper.process_pid(SoundboardWeb.TwitchOutgoingChatHandler)
  defp pub_sub_service(), do: SoundboardWeb.ProcessHelper.process_pid(SoundboardWeb.TwitchPubSub)

  defp obs_websocket_service(), do: SoundboardWeb.ProcessHelper.process_pid(SoundboardWeb.ObsWebsocket)
end
