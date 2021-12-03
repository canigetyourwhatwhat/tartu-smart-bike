defmodule TartuSmarterBike.Repo.Migrations.CreatePrepaidCards do
  use Ecto.Migration

  def change do
    create table(:prepaid_cards) do
      add :number, :string
      add :used, :boolean
      add :value, :integer
      timestamps()
    end
  end
end
