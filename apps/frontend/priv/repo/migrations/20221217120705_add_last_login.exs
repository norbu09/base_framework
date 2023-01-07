defmodule Frontend.Repo.Migrations.AddLastLogin do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add_if_not_exists(:last_login_at, :utc_datetime_usec)
    end
  end
end
