defmodule Frontend.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add_if_not_exists(:role, :integer, default: 0)
    end
  end
end
