import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :tartu_smarter_bike, TartuSmarterBike.Repo,
  username: "postgres",
  password: "helloworld",
  database: "tartu_smarter_bike_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tartu_smarter_bike, TartuSmarterBikeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  secret_key_base: "jar5GxDPnD5FOjKqz4sNF0hfrg71+L6klz+xJoHw0s98crWviFidTEzHVrW6v/+C",
  server: true

# In test we don't send emails.
config :tartu_smarter_bike, TartuSmarterBike.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :hound, driver: "chrome_driver"
config :tartu_smarter_bike, sql_sandbox: true
