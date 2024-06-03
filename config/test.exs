import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kkalb, KkalbWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8A0Aq6HADTR1KytrgJp0SvrRvt9LzinxI+Lz+eQwAaBVjXDb6CpwUb4NjtugeVKu",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :kkalb, Oban, testing: :inline
