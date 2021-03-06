# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :base_framework, BaseFrameworkWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: BaseFrameworkWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BaseFramework.PubSub,
  live_view: [signing_salt: "+DfbCeOP"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :base_framework, BaseFramework.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
    node: [
      "build.js",
      cd: Path.expand("../assets/scripts/", __DIR__),
      env: %{"ESBUILD_LOG_LEVEL" => "silent", "ESBUILD_WATCH" => "1", "NODE_ENV" => "development"}
    ]

config :ex_aws,
  json_codec: Jason,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, {:awscli, "default", 30}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, {:awscli, "default", 30}, :instance_role],
  region: "eu-central-1"

# got issues with AWS requests from fly.io - maybe this fixes it
config :ex_aws, :hackney_opts,
  follow_redirect: true,
  recv_timeout: 30_000

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# pardall_markdown config
config :base_framework, PardallMarkdown.Content,
  site_name: "Base Framework",
  site_description: "a good starting point.",
  s3_bucket: "base-framework.content"

config :pardall_markdown, PardallMarkdown.Content,
  # Where all of the uncompiled assets and content will live on
  # (the Markdown files and any static asset). In this path
  # you will create and update content.
  #
  # This can be any relative or absolute path,
  # including outside of the application.
  root_path: "./local_cache",

  # The path that contains static assets,
  # those files won't be parsed.
  static_assets_path: "./local_cache/static",

  # ETS tables names
  cache_name: :content_cache,
  index_cache_name: :content_index_cache,

  # How often in ms the FileWatcher should check for
  # new or modified content in the `root_path:`?
  recheck_pending_file_events_interval: 1_000,

  # Should the main content tree contain a link to the Home/Root page ("/")?
  content_tree_display_home: false,

  # Should internal <a href/> links be converted to `Phoenix.LiveView` links?
  # If you are using PardallMarkdown with a `Phoenix.LiveView` application, you
  # definitely want this as `true`.
  convert_internal_links_to_live_links: true,

  # Markdown files can contain a top section with metadata/attributes related
  # to the file. Is the metadata required?
  is_markdown_metadata_required: true,

  # Are posts set as draft (unpublished) by default? If true, posts will appear
  # in the content trees only when they have the attribute `published: true`
  # (which sets `Post.is_published == true`). Draft posts can be retrieved
  # only by calling their slug directly with `Repository.get_by_slug/1`
  is_content_draft_by_default: true,

  # Which parser to use to parse a Markdown file's metadata?
  # See the documentation section *Markdown file metadata and attributes*
  metadata_parser: PardallMarkdown.MetadataParser.ElixirMap,

  # Callback to be called every time the content and the indexes are rebuilt.
  #
  # For example, you can put a reference to a function that calls Endpoint.broadcast!:
  # notify_content_reloaded: &MyPhoenixApp.content_reloaded/0
  #
  # Definition:
  # def content_reloaded do
  #   Application.ensure_all_started(:my_phoenix_app) # Recommended
  #   MyPhoenixApp.Endpoint.broadcast!("pardall_markdown_web", "content_reloaded", :all)
  # end
  notify_content_reloaded: &BaseFrameworkWeb.Content.content_reloaded/0


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
