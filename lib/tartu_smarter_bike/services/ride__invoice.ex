defmodule TartuSmarterBike.Services.Ride_Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ride_invoices" do
    field :amount, :integer

    belongs_to :user, TartuSmarterBike.Accounts.User
    belongs_to :ride, TartuSmarterBike.Services.Ride

    timestamps()
  end

  @doc false
  def changeset(ride__invoice, attrs) do
    ride__invoice
    |> cast(attrs, [:amount, :user_id, :ride_id])
    |> validate_required([])
  end
end
