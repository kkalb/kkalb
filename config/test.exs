import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
alias Ecto.Adapters.SQL.Sandbox

config :kkalb, Kkalb.Repo,
  username: "postgres",
  password: "postgres",
  database: "kkalb_repo_test",
  hostname: "localhost",
  pool: Sandbox

config :kkalb, KkalbWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8A0Aq6HADTR1KytrgJp0SvrRvt9LzinxI+Lz+eQwAaBVjXDb6CpwUb4NjtugeVKu",
  server: true

config :kkalb, :sandbox, Sandbox

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :wallaby, :chromedriver, binary: "/usr/local/bin/chromedriver"
config :wallaby, otp_app: :kkalb, driver: Wallaby.Chrome
