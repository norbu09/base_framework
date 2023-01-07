defmodule FrontendWeb.Admin.DashboardLive.Index do
  use FrontendWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, socket}
  end
end
