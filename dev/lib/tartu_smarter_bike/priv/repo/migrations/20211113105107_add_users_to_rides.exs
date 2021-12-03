defmodule TartuSmarterBike.Repo.Migrations.AddUsersToRides do
  use Ecto.Migration

  def change do
    alter table(:rides) do
      add :user_id, references(:users)
    end
  end
end
