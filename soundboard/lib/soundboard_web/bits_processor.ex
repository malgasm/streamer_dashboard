defmodule SoundboardWeb.BitsProcessor do
  defp send_message(msg), do: SoundboardWeb.MessagingHelper.send_twitch_chat_message(msg)

  def process_message_for_user(user, message) do
    if user.bits && user.bits > 0 do
      # send_message("#{user.username} you got #{user.bits} bits?!")
    end
  end
end
