defmodule FrontendWeb.Oauth.RevokeController do
  @behaviour Boruta.Oauth.RevokeApplication

  use FrontendWeb, :controller

  alias Boruta.Oauth.Error
  alias FrontendWeb.OauthView

  def oauth_module, do: Application.get_env(:frontend, :oauth_module, Boruta.Oauth)

  def revoke(%Plug.Conn{} = conn, _params) do
    conn |> oauth_module().revoke(__MODULE__)
  end

  @impl Boruta.Oauth.RevokeApplication
  def revoke_success(%Plug.Conn{} = conn) do
    send_resp(conn, 200, "")
  end

  @impl Boruta.Oauth.RevokeApplication
  def revoke_error(conn, %Error{
        status: status,
        error: error,
        error_description: error_description
      }) do
    conn
    |> put_status(status)
    |> put_view(OauthView)
    |> render("error.json", error: error, error_description: error_description)
  end
end
