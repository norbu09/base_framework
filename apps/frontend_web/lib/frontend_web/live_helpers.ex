defmodule FrontendWeb.LiveHelpers do
  # use FrontendWeb, :verified_routes
  use Phoenix.Component
  # import Phoenix.LiveView
  alias Frontend.Accounts
  # alias Frontend.Accounts.User

  def assign_defaults(session, socket) do
    assign_new(socket, :current_user, fn ->
      find_current_user(session)
    end)
  end

  defp find_current_user(session) do
    case session["user_token"] do
      nil -> nil
      token -> Accounts.get_user_by_session_token(token)
    end
  end

  def format_time(date) do
    Frontend.Helpers.DateFormat.format_time(date, [])
  end
end
