defmodule TartuSmarterBike.Repo.Migrations.CreateBikes do
  use Ecto.Migration

  def change do
    create table(:bikes) do
      add :id_code, :string
      add :usage_status, :string
      add :locking_status, :string
      add :type, :string

      timestamps([{:type, :utc_datetime}])
    end

    alter table(:rides) do
      add :bike_id, references(:bikes)
    end
  end
end
