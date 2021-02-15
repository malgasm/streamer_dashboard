defmodule SoundboardWeb.StreamEvents do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "stream_events" do
    field :event_data, :map
    field :event_type, :string
    field :stream_session_id, :id
    belongs_to :stream_user, SoundboardWeb.StreamUsers, foreign_key: :stream_user_id

    timestamps()
  end

  def create_event(username, event_type, event_data) do
    user = SoundboardWeb.StreamUsers.find_or_create_user(username)

    Soundboard.Repo.insert(
      changeset(%SoundboardWeb.StreamEvents{},
        %{
          stream_user_id: user.id,
          event_type: event_type,
          event_data: event_data
        }
      )
    )
  end

  def all_events() do
    (from u in SoundboardWeb.StreamEvents, preload: [:stream_user])
    |> Soundboard.Repo.all
  end

  @doc false
  def changeset(stream_events, attrs) do
    stream_events
    |> cast(attrs, [:event_type, :event_data, :stream_user_id])
    |> validate_required([:event_type, :event_data])
  end
end
