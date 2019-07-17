defmodule SoundboardWeb.SoundsView do
  use SoundboardWeb, :view

  def render("index.json", %{sounds: sounds}) do
    IO.puts "render"
    IO.inspect sounds
    %{
      sounds: render_many(sounds, __MODULE__, "sound.json", as: :sound)
    }
  end

  def render("sound.json", %{sound: sound}) do
    %{
      id: sound.key,
      key: sound.key,
      path: sound.path
    }
  end
end
