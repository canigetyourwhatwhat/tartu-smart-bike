defmodule TartuSmarterBike.Services.Dock_station do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dock_stations" do
    field :address, :string
    field :longitude, :float
    field :latitude, :float
    field :capacity, :integer
    field :available_bikes, :integer

    has_one :bike, TartuSmarterBike.Accounts.Bike
    timestamps()
  end

  @doc false
  def changeset(dock_station, attrs) do
    dock_station
    |> cast(attrs, [:address, :longitude, :latitude, :available_bikes, :capacity])
    |> cast_assoc(:bike)
    |> validate_required([:address, :longitude, :latitude, :available_bikes, :capacity])
  end
end
