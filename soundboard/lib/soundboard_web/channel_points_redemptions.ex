defmodule SoundboardWeb.ChannelPointsRedemptions do
  require Logger
  @emote_only_one_minute_delay 60 * 1000
  @redemptions %{
  }

  def handle_redemption(user, redemption, entered_text) do
    case redemption do
      "grinGasm" ->
        SoundboardWeb.MessagingHelper.broadcast_new_animation_event("grin", 50)
      "soonerChamp" ->
        SoundboardWeb.MessagingHelper.broadcast_new_animation_event("soonerchamp", 50)
      "Emote-Only for a Minute" ->
        send(outgoing_chat_service(), :enable_emoteonly)
        Process.send_after(outgoing_chat_service(), :disable_emoteonly, @emote_only_one_minute_delay)
      _ ->
        Logger.debug "Unhandled redemption #{inspect redemption} from user #{user}"
    end
  end

  defp outgoing_chat_service(), do: SoundboardWeb.ProcessHelper.process_pid(SoundboardWeb.TwitchOutgoingChatHandler)
  defp pub_sub_service(), do: SoundboardWeb.ProcessHelper.process_pid(SoundboardWeb.TwitchPubSub)
end
