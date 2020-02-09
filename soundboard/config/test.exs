use Mix.Config

# Configure your database
config :soundboard, Soundboard.Repo,
  username: "postgres",
  password: "postgres",
  database: "soundboard_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :soundboard, SoundboardWeb.Endpoint,
  http: [port: 4002],
  server: false
  debug_errors: true

# Print only warnings and errors during test
config :logger, level: :warn

import_config "test.secret.exs"
