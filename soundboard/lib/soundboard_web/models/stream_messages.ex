defmodule SoundboardWeb.StreamMessages do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "stream_messages" do
    field :message_text, :string
    belongs_to :stream_user, SoundboardWeb.StreamUsers, foreign_key: :stream_user_id

    timestamps
  end

  def latest_messages() do
    (from u in SoundboardWeb.StreamMessages,
     preload: [:stream_user],
     order_by: [desc: :inserted_at],
     limit: 50
    )
    |> Soundboard.Repo.all
  end

  def all_messages() do
    (from u in SoundboardWeb.StreamMessages, preload: [:stream_user])
    |> Soundboard.Repo.all
  end

  def create_message(username, message) do
    user = SoundboardWeb.StreamUsers.find_or_create_user(username)

    Soundboard.Repo.insert(
      changeset(%SoundboardWeb.StreamMessages{},
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
