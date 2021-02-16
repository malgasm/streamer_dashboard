defmodule Soundboard.MixProject do
  use Mix.Project

  def project do
    [
      app: :soundboard,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    applications = if Mix.env == :test do
      [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext, :exirc, :websockex]
    else
      [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext, :exirc, :websockex, :gun]
    end

    [
      applications: applications,
      mod: {Soundboard.Application, []},
      extra_applications: [:logger, :runtime_tools, :ecto, :postgrex, :httpoison]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cors_plug, "~> 1.2"},
      {:exirc, "~> 1.1"},
      {:floki, "~> 0.21.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:huex, git: "https://github.com/brousalis/huex.git"},
      {:finch, "~> 0.5"},
      {:mock, "~> 0.3.0", only: [:test]},
			{:nostrum, "~> 0.4"},
      {:phoenix, "~> 1.4.7"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:rcon, "~> 0.4.0"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.5", override: true},
      {:cowlib, "~> 2.7.3", override: true},
      {:tesla, "~> 1.2.1"},
      {:yaml_elixir, "~> 2.4.0"},
      {:yamlix, git: "https://github.com/malgasm/yamlix.git"},
      {:websockex, "~> 0.4.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
