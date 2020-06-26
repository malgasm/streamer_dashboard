defmodule Soundboard.Repo.Migrations.AddUserIdToStreamEvents do
  use Ecto.Migration

  def change do
    alter table(:stream_events) do
      add :stream_user_id, references(:stream_users)
    end
  end
end
