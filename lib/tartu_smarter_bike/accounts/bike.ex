defmodule TartuSmarterBike.Accounts.Bike do
  use Ecto.Schema
  import Ecto.Changeset

  alias TartuSmarterBike.Services.Dock_station
  import Ecto.Query, only: [from: 2]

  schema "bikes" do
    field :id_code, :string
    field :usage_status, :string
    field :locking_status, :string
    field :type, :string

    has_one :ride, TartuSmarterBike.Services.Ride
    has_one :report, TartuSmarterBike.Services.Report
    belongs_to :dock_station, TartuSmarterBike.Services.Dock_station
    timestamps()
  end

  @doc false
  #def changeset(bike, attrs) do
  def changeset(bike, attrs \\ :empty, type \\ :insert) do
    changeset= bike
      |> cast(attrs, [:id_code, :usage_status, :locking_status, :type, :dock_station_id])
      |> cast_assoc(:ride)
      |> validate_required([:id_code, :usage_status, :locking_status, :type, :dock_station_id])

    case type do
      :insert ->
        validate_bike_limit(changeset, [:dock_station_id])
      :update ->
        changeset
    end
  end

  def validate_bike_limit(changeset, field) do
      dock_id = get_field(changeset, :dock_station_id)
      dock = TartuSmarterBike.Repo.one(from d in Dock_station, where: d.id == ^dock_id, select: d)
      if dock.capacity == dock.available_bikes do
        add_error(changeset, field, "can't fit more bikes")
      else
        changeset2 = Dock_station.changeset(dock, %{})
        |> Ecto.Changeset.put_change(:available_bikes, (dock.available_bikes + 1))
        TartuSmarterBike.Repo.update(changeset2)
        changeset
      end
  end

end
