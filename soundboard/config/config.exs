# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :soundboard,
  ecto_repos: [Soundboard.Repo]

config :phoenix_live_reload,
  backend: :fs_poll

# Configures the endpoint
config :soundboard, SoundboardWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1vES8jbzQfrAdx6Ap7BIGkZn65GYLLztftb75Hd9ScmP/dnawkG6NOKwx0rzZWXu",
  render_errors: [view: SoundboardWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Soundboard.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :nostrum,
  token: System.get_env("DISCORD_BOT_TOKEN"),
  num_shards: 2
