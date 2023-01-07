defmodule Frontend.Repo.RolesEnum do
  use EctoEnum, user: 0, beta: 1, admin: 2

  def types do
    [:user, :beta, :admin]
  end
end
