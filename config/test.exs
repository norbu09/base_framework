import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :base_framework, BaseFrameworkWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "LDNz+KSVMQjBuM99mbUSzWbkgalLVQDEZ935epjQsSJDyvNoEqyISTjt5brSJZNc",
  server: false

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

# In test we don't send emails.
config :base_framework, BaseFramework.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
