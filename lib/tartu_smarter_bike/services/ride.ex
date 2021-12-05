defmodule TartuSmarterBike.Services.Ride do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rides" do
    field :distance, :integer, default: 0
    field :departure, :string
    field :destination, :string, default: " "
    field :status, :string, default: "on-going"
    field :reported, :boolean, default: false
    field :fee, :integer

    belongs_to :bike, TartuSmarterBike.Accounts.Bike
    belongs_to :user, TartuSmarterBike.Accounts.User
    has_one :ride_invoice, TartuSmarterBike.Services.Ride_Invoice
    timestamps()
  end

  @doc false
  def changeset(ride, attrs) do
    ride
    |> cast(attrs, [:departure, :destination, :distance])
    |> validate_required([])
  end
end
