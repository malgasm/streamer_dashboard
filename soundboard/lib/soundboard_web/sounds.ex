defmodule SoundboardWeb.Sounds do
  def get_sounds do
    SoundboardWeb.Filesystem.list_files("sounds")
  end

  def get_sound_relative_path_for_web(sound) do
    sound_key = String.to_atom(sound)
    {sound_key, path} = List.keyfind(get_sounds, sound_key, 0)
    path
  end
end
