defmodule Soundboard.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def change do
    create table(:stream_sessions) do
      timestamps([type: :utc_datetime_usec])
    end

    create table(:stream_users) do
      add :username, :string
      add :stream_session_id, references(:stream_sessions)

      timestamps([type: :utc_datetime_usec])
    end

    create table(:stream_events) do
      add :event_type, :string
      add :event_data, :map
      add :stream_session_id, references(:stream_sessions)

      timestamps([type: :utc_datetime_usec])
    end

    create table(:messages) do
      add :stream_session_id, references(:stream_sessions)
      add :stream_user_id, references(:stream_users)

      timestamps([type: :utc_datetime_usec])
    end

    create table(:emotes) do
      add :channel, :string
      add :matching_text, :string
      add :urls, :map
      add :default_url, :string

      timestamps([type: :utc_datetime_usec])
    end
  end
end
