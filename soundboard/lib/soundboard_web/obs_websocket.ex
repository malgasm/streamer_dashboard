defmodule SoundboardWeb.ObsWebsocket do
  use WebSockex
  require Logger

  def start_link(state \\ []) do
    # WebSockex.start_link("wss://echo.websocket.org/?encoding=text", __MODULE__, :fake_state, opts)

    #todo: make the url an env var
    {:ok, pid} =  WebSockex.start_link("ws://192.168.1.9:4444", __MODULE__, state)

    WebSockex.send_frame(pid, {:text, request_params("GetAuthRequired")})
    {:ok, pid}
  end

  @spec echo(pid, String.t) :: :ok
  def echo(client, message) do
    Logger.info("Sending message: #{message}")
    WebSockex.send_frame(client, {:text, message})
  end

  defmacro wrap_obs_function(client, do: yield) do
    quote do
      #todo: have this be configurable
      disable_studio_mode(unquote(client))
      unquote(yield)
      enable_studio_mode(unquote(client))
    end
  end

  def hide_camera(client) do
    #todo: configurable cam scene
    wrap_obs_function(client) do
      echo(client, request_params("SetSceneItemProperties", %{item: "cam", visible: false}))
    end
  end

  def show_camera(client) do
    #todo: configurable cam scene
    wrap_obs_function(client) do
      echo(client, request_params("SetSceneItemProperties", %{item: "cam", visible: true}))
    end
  end

  defp enable_studio_mode(client) do
    echo(client, request_params("EnableStudioMode"))
  end

  defp disable_studio_mode(client) do
    echo(client, request_params("DisableStudioMode"))
  end

  def move_camera(client, x \\ nil, y \\ nil) do
    #todo: configurable cam scene
    pos_params = %{}
    pos_params = if x != nil do
      Map.merge(pos_params, %{x: x})
    else
      pos_params
    end

    pos_params = if y != nil do
      Map.merge(pos_params, %{y: y})
    else
      pos_params
    end

    #Enum.map(1..2500, fn(x) -> move_camera(client, x, 800))
    wrap_obs_function(client) do
      echo(client, request_params("SetSceneItemProperties", Map.merge(%{"position": pos_params}, %{item: "cam"})))
    end
  end

  def generic_command(client, action, params) do
    wrap_obs_function(client) do
      echo(client, request_params(action, Map.merge(params, %{item: "cam"})))
    end
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def handle_frame({:text, json_response}, state) do
    handle_json Jason.decode!(json_response), state
  end

  defp handle_json(%{"authRequired" => true, "challenge" => challenge, "message-id" => message_id, "salt" => salt, "status" => "ok"}, state) do
    IO.puts "salty #{salt}"
    password = "malgasm" #todo: move this to an env variable

    pass_salt = password <> salt
    hash = SoundboardWeb.Utility.sha256_base64_hash(pass_salt)
    hash_challenge = hash <> challenge
    hash = SoundboardWeb.Utility.sha256_base64_hash(hash_challenge)

    {:reply, {:text, request_params("Authenticate", %{auth: hash}, "12345")}, state}
  end

  defp handle_json(json, state) do
    if json["update-type"] do
      #noop
    else
      IO.puts "handle_json uncaught message #{inspect json}"
    end
    {:ok, state}
  end

  def handle_frame({:text, "Can you please reply yourself?" = msg}, :fake_state) do
    Logger.info("Received Message: #{msg}")
    msg = "Sure can!"
    Logger.info("Sending message: #{msg}")
    {:reply, {:text, msg}, :fake_state}
  end

  def handle_frame({:text, "Close the things!" = msg}, :fake_state) do
    Logger.info("Received Message: #{msg}")
    {:close, :fake_state}
  end

  def handle_frame({:text, msg}, :fake_state) do
    Logger.info("Received Message: #{msg}")
    {:ok, :fake_state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect reason}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  defp request_params(request_type, other_params \\ %{}, message_id \\ "1234") do
    Map.merge(%{
      "request-type": request_type,
      "message-id": message_id
    }, other_params)
    |> Jason.encode!
  end
end
