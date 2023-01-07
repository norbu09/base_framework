defmodule FrontendWeb.PageController do
  use FrontendWeb, :controller
  require Logger

  def home(conn, _params) do
    render(conn, :home)
  end

  def terms(conn, _params) do
    render(conn, :terms)
  end

  def privacy(conn, _params) do
    render(conn, :privacy)
  end

  def blog(conn, _params) do
    render(conn, :blog)
  end

end
