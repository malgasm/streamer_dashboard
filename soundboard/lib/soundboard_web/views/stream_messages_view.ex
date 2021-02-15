defmodule SoundboardWeb.StreamMessagesView do
  use SoundboardWeb, :view

  def render("index.json", %{messages: messages}) do
    %{
      stream_messages: render_many(messages, __MODULE__, "message.json", as: :message)
    }
  end

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      text: message.message_text,
      user: message.stream_user.username
    }
  end
end
