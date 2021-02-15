defmodule SoundboardWeb.StreamEmotes do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stream_emotes" do
    field :channel, :string
    field :default_url, :string
    field :matching_text, :string
    field :urls, :map

    timestamps()
  end

  @doc false
  def changeset(stream_emotes, attrs) do
    stream_emotes
    |> cast(attrs, [:channel, :matching_text, :urls, :default_url])
    |> validate_required([:channel, :matching_text, :urls, :default_url])
  end
end
