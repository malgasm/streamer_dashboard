defmodule Soundboard.SoundboardWeb.StreamEvents do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stream_events" do
    field :event_data, :map
    field :event_type, :string
    field :stream_session_id, :id

    timestamps()
  end

  @doc false
  def changeset(stream_events, attrs) do
    stream_events
    |> cast(attrs, [:event_type, :event_data])
    |> validate_required([:event_type, :event_data])
  end
end
