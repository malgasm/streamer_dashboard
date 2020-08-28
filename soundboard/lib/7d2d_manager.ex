defmodule SoundboardWeb.SevenDaysManager do
  def stop do
    manage_sevendays("stop")
  end

  def start do
    manage_sevendays("start")
  end

  def backup do
    manage_sevendays("backup")
  end

  def status do
    manage_sevendays("status")
  end

  def test do
    IO.puts "testing?"
    manage_sevendays("")
  end

  defp handle_manage_result({msg, 0}), do: msg
  defp handle_manage_result({msg, 1}), do: "eek! something went wrong. #{msg}"

  defp manage_sevendays(cmd) do
    System.cmd("/home/m/7d2d_manage", [cmd]) |> handle_manage_result
  end
end
