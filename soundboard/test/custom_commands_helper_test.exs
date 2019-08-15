defmodule SoundboardWeb.CustomCommandsHelperTest do
  use ExUnit.Case

  defp user(username, isMod, isSub), do: %{username: username, isMod: isMod, isSub: isSub}
  defp user(), do: %{username: "test", isMod: false, isSub: false}

  test "test name" do
  end

end
