defmodule Soundboard.Repo.Migrations.ChangeMessageTypeToText do
  use Ecto.Migration

  def change do
    alter table(:stream_messages) do
      modify :message_text, :text
    end
  end
end
