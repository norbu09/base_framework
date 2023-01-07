defmodule FrontendWeb.Admin.ClientsLive.Show do
  use FrontendWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:clients, Boruta.Ecto.Admin.get_client!(id))}
  end

  defp page_title(:show), do: "Show Clients"
  defp page_title(:edit), do: "Edit Clients"
end
