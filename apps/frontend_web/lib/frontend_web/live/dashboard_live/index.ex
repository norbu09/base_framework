defmodule FrontendWeb.DashboardLive.Index do
  use FrontendWeb, :live_view
  require Logger

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    params = %{}
    Logger.debug("Current user: #{inspect(socket.assigns)}")

    {:ok,
     socket
     |> assign(:params, params)
     |> assign(:page_title, "dashboard")
     |> assign(:changeset, true)}
  end

end
