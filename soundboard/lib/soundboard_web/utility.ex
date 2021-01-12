defmodule SoundboardWeb.Utility do
  def intersect(a, b), do: a -- (a -- b)

  def find_occurrences(emote, message) do
    count = String.split(message, emote) |> Kernel.length
    if count > 0 do
      count - 1
    else
      count
    end
  end
end
