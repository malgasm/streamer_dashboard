defmodule SoundboardWeb.Filesystem do
  def read_file(path) do
    process_file_read(File.read(Path.expand("./files/" <> path)))
  end

  def write_file(content, path) do
    {:ok, file} = File.open(Path.expand("./files/" <> path), [:write])
    IO.binwrite(file, content)
  end

  def list_files(path, sounds \\ []) do
    process_ls_result File.ls(get_assets_path(path)), get_assets_path(path), sounds
  end

  defp get_assets_path(path), do: Path.expand("./assets/static/" <> path)

  defp process_file_read({:ok, file}), do: file
  defp process_file_read({:error, error}), do: error

  #creates sound objects in an ember-friendly format
  defp process_ls_result({:ok, files}, path, sounds) do
    sounds_list = List.flatten(Enum.map(files, fn(entry) ->
      sounds = sounds ++ if String.contains?(entry, ".") do #is a file
        [%{key: get_filename_without_extension(entry), path: relative_asset_path(path <> entry)}]
      else
        List.flatten(process_ls_result(File.ls("#{path}/#{entry}/"), "#{path}/#{entry}/", sounds))
      end
      Enum.uniq(sounds)
    end))
  end

  # creates sound objects in tuple format
  # defp process_ls_result({:ok, files}, path, sounds) do
  #   sounds_list = List.flatten(Enum.map(files, fn(entry) ->
  #     sounds = sounds ++ if String.contains?(entry, ".") do #is a file
  #       [{String.to_atom(get_filename_without_extension(entry)), relative_asset_path(path <> entry)}]
  #     else
  #       List.flatten(process_ls_result(File.ls("#{path}/#{entry}/"), "#{path}/#{entry}/", sounds))
  #     end
  #     Enum.uniq(sounds)
  #   end))
  # end

  defp relative_asset_path(fullpath) do
    String.replace(fullpath, Path.expand("./assets/static"), "")
  end

  defp process_ls_result({:error, error}, path, sounds), do: error

  defp get_filename_without_extension(file), do: Enum.join(Enum.slice(String.split(file, "."), 0, Kernel.length(String.split(file, ".")) - 1), ".")
end
