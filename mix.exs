defmodule Blog.Mixfile do
  use Mix.Project

  def project() do
    [app: :blog,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application() do
    [mod: {Blog, []},
     applications: [:phoenix, :phoenix_pubsub, :cowboy, :logger,
                    :phoenix_ecto, :postgrex, :absinthe_plug]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps() do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:absinthe, "~> 1.2.0-rc.0", override: true},
     {:absinthe_plug, "~> 1.2.0-rc.0"},
     {:postgrex, ">= 0.0.0"},
     {:cors_plug, ">= 0.0.0"},
     {:timex, ">= 0.0.0"},
     {:cowboy, "~> 1.0"}]
  end

end
