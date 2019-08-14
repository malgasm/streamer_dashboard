defmodule SoundboardWeb.Sounds do
  def get_sounds do
    SoundboardWeb.Filesystem.list_files("sounds")
  end

  def get_sound_names do
    get_sounds
    |> Enum.map(fn(sound) -> sound.key end)
  end

  def get_random_sound(sounds), do: Enum.random(sounds)

  def get_sound_relative_path_for_web(sound) do
    %{key: sound_key, path: path} = Enum.at(Enum.filter(get_sounds, fn(item) -> item.key == sound end), 0)
    path
  end
end
