defmodule TartuSmarterBike.Repo.Migrations.AddDockIdToBike do
  use Ecto.Migration

  def change do
      alter table(:bikes) do
        add :dock_station_id, references(:dock_stations)
      end
  end
end
