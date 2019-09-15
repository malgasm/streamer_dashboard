defmodule SoundboardWeb.TwitchApi do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.twitch.tv/helix"
  plug Tesla.Middleware.Headers, [{"Client-ID:", Application.get_env(:soundboard, :twitch_client_id)}]
  plug Tesla.Middleware.JSON

  #in order to correctly implement this, we'll need to use token exchange, as detailed here https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#oauth-client-credentials-flow

  def get_user(username) do
    get("/users?login=#{username}")
  end

end
