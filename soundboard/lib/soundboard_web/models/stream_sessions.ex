defmodule SoundboardWeb.StreamSessions do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "stream_sessions" do

    timestamps()
  end

  def find_or_create_stream_session(id) do
    stream_session = find_stream_session(id)
    |> handle_find_stream_session
  end

  defp handle_find_stream_session(nil) do
    Soundboard.Repo.insert(changeset(%SoundboardWeb.StreamSessions{}, %{}))
  end

  defp handle_find_stream_session(stream_session), do: stream_session

  defp find_stream_session(id) do
    (from s in SoundboardWeb.StreamSessions,
      where: s.id == ^id)
    |> Soundboard.Repo.one
  end

  defp find_stream_session_if_already_created(derp, stream_session), do: stream_session

  @doc false
  def changeset(stream_sessions, attrs) do
    stream_sessions
    |> cast(attrs, [])
    |> validate_required([])
  end
end
