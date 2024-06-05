defmodule Kkalb.MixProject do
  use Mix.Project

  def project do
    [
      app: :kkalb,
      version: "1.0.11",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: preferred_cli_env(),
      dialyzer: [
        plt_add_apps: [:mix, :ecto],
        flags: [:unmatched_returns, :error_handling, :underspecs, :no_opaque]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Kkalb.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:phoenix, "~> 1.7.7"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.19.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:finch, "~> 0.13"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 2.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:postgrex, ">= 0.0.0"},
      {:oban, "~> 2.17"}
    ]
  end

  defp preferred_cli_env() do
    ["ecto.reset": :test]
  end

  # do not apply seeds on dev right now
  defp ecto_reset(:test), do: ecto_reset(:dev) ++ ["run priv/repo/seeds.exs"]
  defp ecto_reset(:dev), do: ["ecto.drop", "ecto.create", "ecto.migrate"]
  defp ecto_reset(_), do: []

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.reset": ecto_reset(Mix.env()),
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "cmd cp -r assets/js/particles.json priv/static/assets",
        "phx.digest"
      ],
      "copy.static.assets": [
        "cmd rm -rf priv/static/images",
        "cmd cp -r assets/images priv/static/images",
        "cmd cp -r assets/js/particles.json priv/static/assets"
      ],
      ps: ["copy.static.assets", "phx.server"]
    ]
  end
end
