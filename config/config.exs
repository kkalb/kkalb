# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# default config for repo, will be overridden in other config files
config :kkalb, Kkalb.Repo,
  database: "kkalb_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  log: false,
  pool_size: 9

# Configures the endpoint
config :kkalb, KkalbWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: KkalbWeb.ErrorHTML, json: KkalbWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Kkalb.PubSub,
  live_view: [signing_salt: "ni1y7ANM"]

config :kkalb, Oban,
  engine: Oban.Engines.Basic,
  queues: [github_fetcher_queue: 10],
  repo: Kkalb.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7}
  ]

config :kkalb, :github, api_key: ""
config :kkalb, ecto_repos: [Kkalb.Repo]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
