defmodule FrontendWeb.Admin.ClientsLive.FormComponent do
  use FrontendWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage client records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="client-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :id}} type="hidden" label="id" />
        <.input field={{f, :name}} type="text" label="name" />
        <.input field={{f, :redirect_uri}} type="url" label="redirect uri" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Clients</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{action: :edit, client: client} = assigns, socket) do
    changeset = Boruta.Ecto.Client.update_changeset(client, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def update(%{action: :new, client: client} = assigns, socket) do
    changeset = Boruta.Ecto.Client.create_changeset(%Boruta.Ecto.Client{}, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:client, client)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"client" => client_params}, socket) do
    params =
      client_params
      |> Map.put("redirect_uris", [client_params["redirect_uri"]])

    changeset =
      case params["id"] do
        "" ->
          id = SecureRandom.uuid()
          secret = SecureRandom.hex(64)

          client = %Boruta.Ecto.Client{
            # OAuth client_id
            id: id,
            # OAuth client_secret
            secret: secret,
            # Display name
            name: "",
            # one day
            access_token_ttl: 60 * 60 * 24,
            # one minute
            authorization_code_ttl: 60,
            # one month
            refresh_token_ttl: 60 * 60 * 24 * 30,
            # one day
            id_token_ttl: 60 * 60 * 24,
            # ID token signature algorithm, defaults to "RS512"
            id_token_signature_alg: "RS256",
            # OAuth client redirect_uris
            redirect_uris: ["http://redirect.uri"],
            # take following authorized_scopes into account (skip public scopes)
            authorize_scope: false,
            # scopes that are authorized using this client
            authorized_scopes: [],
            # client supported grant types
            supported_grant_types: [
              "client_credentials",
              "password",
              "authorization_code",
              "refresh_token",
              "implicit",
              "revoke",
              "introspect"
            ],
            # PKCE enabled
            pkce: false,
            # do not require client_secret for refreshing tokens
            public_refresh_token: false,
            # do not require client_secret for revoking tokens
            public_revoke: false
          }

          client
          |> Boruta.Ecto.Client.create_changeset(params)
          |> Map.put(:action, :validate)

        _ ->
          socket.assigns.client
          |> Boruta.Ecto.Client.update_changeset(params)
          |> Map.put(:action, :validate)
      end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"client" => client_params}, socket) do
    save_client(socket, socket.assigns.action, client_params)
  end

  defp save_client(socket, :edit, client_params) do
    params =
      client_params
      |> Map.put("redirect_uris", [client_params["redirect_uri"]])

    case Boruta.Ecto.Admin.update_client(socket.assigns.client, params) do
      {:ok, _client} ->
        {:noreply,
         socket
         |> put_flash(:info, "Clients updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_client(socket, :new, client_params) do
    params =
      client_params
      |> Map.put("redirect_uris", [client_params["redirect_uri"]])

    case Boruta.Ecto.Admin.create_client(params) do
      {:ok, _client} ->
        {:noreply,
         socket
         |> put_flash(:info, "Clients created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
