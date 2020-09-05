defmodule SoundboardWeb.TwitchWebhooks do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.twitch.tv/helix"
  plug Tesla.Middleware.Headers, [{"Client-ID:", System.get_env("TWITCH_CLIENT_ID")}, {"Authorization", "Bearer #{System.get_env("TWITCH_OAUTH_KEY_WEBSOCKET")}"}]
  plug Tesla.Middleware.JSON

  #in order to correctly implement this, we'll need to use token exchange, as detailed here https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#oauth-client-credentials-flow

  def subscribe(topic \\ "") do
  end

end
