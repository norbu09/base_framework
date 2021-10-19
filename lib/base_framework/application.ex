defmodule BaseFramework.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  @local_cache Application.compile_env!(:pardall_markdown, [PardallMarkdown.Content, :root_path])

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BaseFrameworkWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BaseFramework.PubSub},
      # Start the Endpoint (http/https)
      BaseFrameworkWeb.Endpoint,
      # Start a worker by calling: BaseFramework.Worker.start_link(arg)
      # {BaseFramework.Worker, arg}
      BaseFramework.Scheduler
    ]

    # make sure we have a content directory before anything starts
    BaseFramework.Storage.has_content_dir(@local_cache)
    Task.start(BaseFrameworkWeb.Content, :update, [])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BaseFramework.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BaseFrameworkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
