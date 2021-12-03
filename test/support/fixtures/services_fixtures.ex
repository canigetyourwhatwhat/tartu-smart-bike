defmodule TartuSmarterBike.ServicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TartuSmarterBike.Services` context.
  """

  @doc """
  Generate a ride.
  """
  def ride_fixture(attrs \\ %{}) do
    {:ok, ride} =
      attrs
      |> Enum.into(%{
        bike: "some bike",
        distance: 10,
        departure: "some place",
        end_time: "some end_time",
        invoice: "some invoice",
        start_time: "some start_time",
        user: "some user"
      })
      |> TartuSmarterBike.Services.create_ride()

    ride
  end

  @doc """
  Generate a dock_station.
  """
  def dock_station_fixture(attrs \\ %{}) do
    {:ok, dock_station} =
      attrs
      |> Enum.into(%{
        address: "some address",
        longitude: 0.0,
        latitude: 0.0,
        capacity: 10,
        available_bikes: 5
      })
      |> TartuSmarterBike.Services.create_dock_station()

    dock_station
  end
end
