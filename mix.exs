defmodule Blog.Mixfile do
  use Mix.Project

  def project do
    [
      app: :blog,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Blog.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:absinthe, "~> 1.4"},
      {:absinthe_ecto, ">= 0.0.0"},
      {:absinthe_plug, "~> 1.4"},
      {:argon2_elixir, "~> 2.0.5"},
      {:comeonin, "~> 5.1.2"},
      {:cowboy, "~> 2.6.3"},
      {:ecto_sql, "~> 3.2.0"},
      {:gettext, "~> 0.11"},
      {:jason, ">= 0.0.0"},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_ecto, ">= 0.0.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:plug_cowboy, "~> 2.1.0"},
      {:postgrex, ">= 0.0.0"},
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
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
