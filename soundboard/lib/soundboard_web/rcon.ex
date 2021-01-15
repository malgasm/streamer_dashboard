defmodule SoundboardWeb.Rcon do
  require Logger

  defp connect do
    RCON.Client.connect(System.get_env("RUST_RCON_HOST"), String.to_integer(System.get_env("RUST_RCON_PORT")))
  end

  defp authenticate do

  end
end
