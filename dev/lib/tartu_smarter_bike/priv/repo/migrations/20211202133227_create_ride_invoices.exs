defmodule TartuSmarterBike.Repo.Migrations.CreateRideInvoices do
  use Ecto.Migration

  def change do
    create table(:ride_invoices) do
      add :amount, :integer
      add :user_id, references(:users)
      add :ride_id, references(:rides)

      timestamps()
    end
  end
end
