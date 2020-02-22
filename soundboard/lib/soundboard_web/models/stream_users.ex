defmodule Soundboard.SoundboardWeb.StreamUsers do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "stream_users" do
    field :username, :string
    has_many :stream_messages, Soundboard.SoundboardWeb.StreamMessages, foreign_key: :stream_user_id

    timestamps()
  end

  def find_or_create_user(nil) do
    nil
  end

  def find_or_create_user(username) when is_binary(username) do
    user = handle_create_user(Soundboard.Repo.insert(
      changeset(%Soundboard.SoundboardWeb.StreamUsers{}, %{username: sanitize_username(username)}),
        on_conflict: :nothing
      )
    )
    find_user_if_already_created(sanitize_username(username), user)
  end

  defp handle_create_user({:error, _}), do: nil

  defp handle_create_user({:ok, %Soundboard.SoundboardWeb.StreamUsers{id: nil}}), do: nil
  defp handle_create_user({:ok, user}), do: user

  defp find_user_if_already_created(username, nil) do
    (from u in Soundboard.SoundboardWeb.StreamUsers,
      where: u.username == ^sanitize_username(username))
    |> Soundboard.Repo.one
  end

  defp find_user_if_already_created(username, user), do: user

  defp sanitize_username(username), do: String.downcase(username)

  @doc false
  def changeset(stream_users, attrs) do
    stream_users
    |> cast(attrs, [:username])
    |> validate_required([:username])
  end
end
