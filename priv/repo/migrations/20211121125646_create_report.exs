defmodule TartuSmarterBike.Repo.Migrations.CreateReport do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :title, :string
      add :description, :string
      add :user_id, references(:users)
      add :bike_id, references(:bikes)

      timestamps([{:type, :utc_datetime}])
    end
  end
end
