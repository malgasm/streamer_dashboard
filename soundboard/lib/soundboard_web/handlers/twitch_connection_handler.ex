defmodule SoundboardWeb.TwitchConnectionHandler do
  require Logger
  alias ExIRC.Client

  def cap_request(client, cap) do
    request = Client.cmd(client, ['CAP ', 'REQ ', cap])
    Logger.debug "Initiating Twitch chat capability request....\n\n\n\n\n\n\n"
  end

  ###### boilerplate

  def handle_info({:unrecognized, "002", msg}, config), do: {:noreply, config}
  def handle_info({:unrecognized, "003", msg}, config), do: {:noreply, config}
  def handle_info({:unrecognized, "004", msg}, config), do: {:noreply, config}
  def handle_info({:unrecognized, "002", msg}, config), do: {:noreply, config}
  def handle_info({:unrecognized, "366", msg}, config), do: {:noreply, config}
  def handle_info({:unrecognized, "375", msg}, config), do: {:noreply, config}
  def handle_info({:unrecognized, "376", msg}, config), do: IO.debug "Connection to twitch succeeded for #{config.nick}"

  def join(client, channels) when is_list(channels) do
    channels
      |> Enum.map(&join(client, &1))

    client
  end

  def join(client, channel) do
    Client.join(client, channel)

    Logger.debug "Joined channel: #{channel}"
  end

  def terminate(_, state) do
    # Quit the channel and close the underlying client connection when the process is terminating
    Client.quit state.client, "Goodbye, cruel world."
    Client.stop! state.client
    :ok
  end
end
