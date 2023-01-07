defmodule FrontendWeb.Admin.ClientsLive.Index do
  use FrontendWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, assign(socket, :clients, list_clients())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Clients")
    |> assign(:client, Boruta.Ecto.Admin.get_client!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New OAuth Client")
    |> assign(:client, %{id: :new})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Client")
    |> assign(:clients, list_clients())
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    client = Boruta.Ecto.Admin.get_client!(id)
    {:ok, _} = Boruta.Ecto.Admin.delete_client(client)

    {:noreply, assign(socket, :clients, list_clients())}
  end

  defp list_clients do
    Boruta.Ecto.Admin.Clients.list_clients()
  end
end
