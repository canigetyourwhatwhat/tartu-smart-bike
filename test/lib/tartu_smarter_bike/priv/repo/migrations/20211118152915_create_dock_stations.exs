defmodule TartuSmarterBike.Repo.Migrations.CreateDockStattions do
  use Ecto.Migration

  def change do
    create table(:dock_stations) do
      add :address, :string
      add :latitude, :float
      add :longitude, :float
      add :capacity, :integer
      add :available_bikes, :integer

      timestamps([{:type, :utc_datetime}])
    end
  end

end
