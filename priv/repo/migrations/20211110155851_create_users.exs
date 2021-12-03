defmodule TartuSmarterBike.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :birthdate, :date
      add :email, :string
      add :password, :string
      add :balance, :float
      add :card_number, :string
      add :subscription_type, :string
      add :expiration_date, :utc_datetime
      timestamps([{:type, :utc_datetime}])
    end
  end
end
