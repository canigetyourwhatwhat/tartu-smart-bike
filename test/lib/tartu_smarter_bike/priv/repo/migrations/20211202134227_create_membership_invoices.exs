defmodule TartuSmarterBike.Repo.Migrations.CreateMembershipInvoices do
  use Ecto.Migration

  def change do
    create table(:membership_invoices) do
      add :amount, :integer
      add :membership, :string
      add :user_id, references(:users)
      timestamps()
    end
  end
end
