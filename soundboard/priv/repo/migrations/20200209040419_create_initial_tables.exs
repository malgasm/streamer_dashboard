defmodule Soundboard.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def change do
    create table(:stream_sessions) do
      timestamps([type: :utc_datetime_usec])
    end

    create table(:stream_users) do
      add :username, :string

      timestamps([type: :utc_datetime_usec])
    end
    create unique_index(:stream_users, [:username])

    create table(:stream_events) do
      add :event_type, :string
      add :event_data, :map
      add :stream_session_id, references(:stream_sessions)

      timestamps([type: :utc_datetime_usec])
    end

    create table(:stream_messages) do
      add :message_text, :string
      add :stream_session_id, references(:stream_sessions)
      add :stream_user_id, references(:stream_users)

      timestamps([type: :utc_datetime_usec])
    end

    create table(:stream_emotes) do
      add :channel, :string
      add :matching_text, :string
      add :urls, :map
      add :default_url, :string

      timestamps([type: :utc_datetime_usec])
    end
    create unique_index(:stream_emotes, [:matching_text])
  end
end
