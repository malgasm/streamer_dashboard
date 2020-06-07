defmodule SoundboardWeb.Hue do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [%{}])
  end

  def init([config]) do
    {:ok, Huex.connect("192.168.1.2", Application.get_env(:soundboard, :philips_hue_username))}
  end

  def handle_info({:set_color, color}, bridge) do
    set_light_color(bridge, hex_to_rgb(color) |> rgb_to_hue)
    {:noreply, bridge}
  end

  def handle_call({:hex_to_rgb, hex}, _from, bridge) do #testing
    {:reply, hex_to_rgb(hex), bridge}
  end

  def handle_call({:hex_to_hue, hex}, _from, bridge) do #testing
    {:reply, hex_to_rgb(hex) |> rgb_to_hue, bridge}
  end

  defp hex_to_rgb(hex) do
    Enum.map([0,2,4], fn (segment) ->
      String.slice(sanitize(hex), segment, 2)
      |> String.to_charlist
      |> List.to_integer(16)
    end)
  end

  defp set_light_color(bridge, hue_color) do
    Huex.set_color(bridge, 7, hue_color)
    Huex.set_color(bridge, 8, hue_color)
  end

  defp rgb_to_hue(rgb) do
    converted = Enum.map(rgb, fn segment ->
      segment / 255
    end)
    Huex.Color.rgb(
      Enum.at(converted, 0),
      Enum.at(converted, 1),
      ensure_not_one(Enum.at(converted, 2))
    )
  end

  defp ensure_not_one(1.0), do: 0.99999
  defp ensure_not_one(b_val), do: b_val

  defp sanitize(hex) do
    ensure_hex(hex)
    |> remove_pound_sign
  end

  defp ensure_hex(hex) do
    Regex.replace(remove_non_alpha_regex, hex, "")
    |> String.slice(0, 7)
  end

  defp remove_non_alpha_regex(), do: ~r/[^a-zA-Z0-9]*/

  defp remove_pound_sign(hex) do
    if String.slice(hex, 0, 1) == "#" do
      String.slice(hex, 1, String.length(hex))
    else
      hex
    end
  end
end
