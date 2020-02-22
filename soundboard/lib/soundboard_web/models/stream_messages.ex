defmodule Soundboard.SoundboardWeb.StreamMessages do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "stream_messages" do
    field :message_text, :string
    belongs_to :stream_user, Soundboard.SoundboardWeb.StreamUsers, foreign_key: :stream_user_id

    timestamps()
  end

  def all_messages() do
    (from u in Soundboard.SoundboardWeb.StreamMessages, preload: [:stream_user])
    |> Soundboard.Repo.all
  end

  def create_message(username, message) do
    user = Soundboard.SoundboardWeb.StreamUsers.find_or_create_user(username)

    Soundboard.Repo.insert(
      changeset(%Soundboard.SoundboardWeb.StreamMessages{},
        %{
          stream_user_id: user.id,
          message_text: message
        }
      )
    )
  end

  @doc false
  def changeset(stream_messages, attrs) do
    stream_messages
    |> cast(attrs, [:message_text, :stream_user_id])
    |> validate_required([:message_text])
  end
end
