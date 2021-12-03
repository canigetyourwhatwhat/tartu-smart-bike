defmodule TartuSmarterBike.Services do
  @moduledoc """
  The Services context.
  """

  import Ecto.Query, warn: false
  alias TartuSmarterBike.Repo
  alias TartuSmarterBike.Services.Dock_station

  alias TartuSmarterBike.Services.Ride

  @doc """
  Returns the list of rides.

  ## Examples

      iex> list_rides()
      [%Ride{}, ...]

  """
  def list_rides do
    Ride |> reverse_order() |> Repo.all()
  end

  @doc """
  Gets a single ride.

  Raises `Ecto.NoResultsError` if the Ride does not exist.

  ## Examples

      iex> get_ride!(123)
      %Ride{}

      iex> get_ride!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ride!(id), do: Repo.get!(Ride, id)

  @doc """
  Creates a ride.

  ## Examples

      iex> create_ride(%{field: value})
      {:ok, %Ride{}}

      iex> create_ride(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ride(attrs \\ %{}) do
    %Ride{}
    |> Ride.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ride.

  ## Examples

      iex> update_ride(ride, %{field: new_value})
      {:ok, %Ride{}}

      iex> update_ride(ride, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ride(%Ride{} = ride, attrs) do
    ride
    |> Ride.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ride.

  ## Examples

      iex> delete_ride(ride)
      {:ok, %Ride{}}

      iex> delete_ride(ride)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ride(%Ride{} = ride) do
    Repo.delete(ride)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ride changes.

  ## Examples

      iex> change_ride(ride)
      %Ecto.Changeset{data: %Ride{}}

  """
  def change_ride(%Ride{} = ride, attrs \\ %{}) do
    Ride.changeset(ride, attrs)
  end

  def create_dock_station(attrs \\ %{}) do
    %Dock_station{}
    |> Dock_station.changeset(attrs)
    |> Repo.insert()
  end

  def change_dock_station(%Dock_station{} = dock_station, attrs \\ %{}) do
    Dock_station.changeset(dock_station, attrs)
  end

  def get_dock_station!(id), do: Repo.get!(Dock_station, id)

  def list_dock_stations do
    Repo.all(Dock_station)
  end

  def update_dock_station(%Dock_station{} = dock_station, attrs) do
    dock_station
    |> Dock_station.changeset(attrs)
    |> Repo.update()
  end

  def delete_dock_station(%Dock_station{} = dock_station) do
    Repo.delete(dock_station)
  end
end
