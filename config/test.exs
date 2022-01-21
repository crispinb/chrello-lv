import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chrello, ChrelloWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "3LBl0EcGyYA3fWKFrKj0dCpk17Oe+VkEEoIASj/v1LSJaTXn4ciiiYM3RQGLNbhl",
  server: false

# configures the http/api adapter
# (MockApi set up in test_helper.exs)
config :chrello, api_module: Chrello.MockApi

# In test we don't send emails.
config :chrello, Chrello.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
