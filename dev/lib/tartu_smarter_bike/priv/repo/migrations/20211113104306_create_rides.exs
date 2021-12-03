defmodule TartuSmarterBike.Repo.Migrations.CreateRides do
  use Ecto.Migration

  def change do
    create table(:rides) do
      add :distance, :integer
      add :departure, :string
      add :destination, :string
      add :status, :string
      add :reported, :boolean
      add :fee, :integer
      timestamps([{:type, :utc_datetime}])
    end
  end
end
