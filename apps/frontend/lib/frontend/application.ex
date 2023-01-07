defmodule Frontend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: FrontendFinch},
      Frontend.Repo,
      {Phoenix.PubSub, name: Frontend.PubSub}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Frontend.Supervisor)
  end
end
