import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/kkalb start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :kkalb, KkalbWeb.Endpoint, server: true
end

config :kkalb, :github, api_key: System.get_env("GITHUB_ACCESS_KEY", "")

config :kkalb,
       :issue_storage,
       if(System.get_env("ISSUE_STORAGE_TYPE", "ETS") == "ETS", do: Kkalb.IssuesEts, else: Kkalb.Issues)

if config_env() == :prod do
  # The secret key base is managed by Gigalixir
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host_uri = System.get_env("PHX_HOST") || "http://kkalb_example.com"
  uri = URI.parse(host_uri)

  port = String.to_integer(System.get_env("PORT") || "4000")

  config :kkalb, Kkalb.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: System.get_env("DATABASE_URL"),
    pool_size: "POOL_SIZE" |> System.get_env("9") |> String.to_integer()

  config :kkalb, KkalbWeb.Endpoint, force_ssl: [hsts: true]

  config :kkalb, KkalbWeb.Endpoint,
    url: [host: uri.host, port: uri.port || 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
end
