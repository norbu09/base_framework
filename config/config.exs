# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :base_framework,
  upload_path: "./apps/frontend_web/priv/static/csv",
  feature: [
    test_feature: false
  ]

# Configure Mix tasks and generators
config :frontend,
  ecto_repos: [Frontend.Repo],
  discord_url: "https://.....add_discord_url...."

config :frontend_web, FrontendWeb.Layouts, tracking: false

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :frontend, Frontend.Mailer, adapter: Swoosh.Adapters.Local

# Configures the endpoint
config :frontend_web, FrontendWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: FrontendWeb.ErrorHTML, json: FrontendWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Frontend.PubSub,
  live_view: [signing_salt: "OQFu4R5w"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.42",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/frontend_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/frontend_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# configure OAuth layer
config :boruta, Boruta.Oauth,
  repo: Frontend.Repo,
  issuer: "https://emails.eco",
  contexts: [
    resource_owners: Frontend.ResourceOwners
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
