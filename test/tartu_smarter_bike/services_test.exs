defmodule TartuSmarterBike.ServicesTest do
  use TartuSmarterBike.DataCase

  alias TartuSmarterBike.Services

  describe "rides" do
    alias TartuSmarterBike.Services.Ride

    import TartuSmarterBike.ServicesFixtures

    @invalid_attrs %{bike: nil, departure: nil, end_time: nil, invoice: nil, start_time: nil, user: nil}

    test "list_rides/0 returns all rides" do
      ride = ride_fixture()
      assert Services.list_rides() == [ride]
    end

    test "get_ride!/1 returns the ride with given id" do
      ride = ride_fixture()
      assert Services.get_ride!(ride.id) == ride
    end

    test "create_ride/1 with valid data creates a ride" do
      valid_attrs = %{departure: "some departure"}

      assert {:ok, %Ride{} = ride} = Services.create_ride(valid_attrs)
      assert ride.departure == "some departure"
    end

    test "update_ride/2 with valid data updates the ride" do
      ride = ride_fixture()
      update_attrs = %{departure: "some updated departure"}

      assert {:ok, %Ride{} = ride} = Services.update_ride(ride, update_attrs)
      assert ride.departure == "some updated departure"

    end

    test "delete_ride/1 deletes the ride" do
      ride = ride_fixture()
      assert {:ok, %Ride{}} = Services.delete_ride(ride)
      assert_raise Ecto.NoResultsError, fn -> Services.get_ride!(ride.id) end
    end

    test "change_ride/1 returns a ride changeset" do
      ride = ride_fixture()
      assert %Ecto.Changeset{} = Services.change_ride(ride)
    end
  end

  describe "address" do
    alias TartuSmarterBike.Services.Dock_station

    import TartuSmarterBike.ServicesFixtures

    @invalid_attrs %{capacity: nil}

    test "get_dock_station!/1 returns the dock_station with given id" do
      dock_station = dock_station_fixture()
      assert Services.get_dock_station!(dock_station.id) == dock_station
    end

    test "create_dock_station/1 with valid data creates a dock_station" do
      valid_attrs = %{address: "some address", longitude: 0.0, latitude: 0.0,
      capacity: 10, available_bikes: 5}

      assert {:ok, %Dock_station{} = dock_station} = Services.create_dock_station(valid_attrs)
      assert dock_station.capacity == 10
    end

    test "create_dock_station/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_dock_station(@invalid_attrs)
    end

    test "update_dock_station/2 with valid data updates the dock_station" do
      dock_station = dock_station_fixture()
      update_attrs = %{capacity: 11}

      assert {:ok, %Dock_station{} = dock_station} = Services.update_dock_station(dock_station, update_attrs)
      assert dock_station.capacity == 11
    end

    test "update_dock_station/2 with invalid data returns error changeset" do
      dock_station = dock_station_fixture()
      assert {:error, %Ecto.Changeset{}} = Services.update_dock_station(dock_station, @invalid_attrs)
      assert dock_station == Services.get_dock_station!(dock_station.id)
    end

    test "delete_dock_station/1 deletes the dock_station" do
      dock_station = dock_station_fixture()
      assert {:ok, %Dock_station{}} = Services.delete_dock_station(dock_station)
      assert_raise Ecto.NoResultsError, fn -> Services.get_dock_station!(dock_station.id) end
    end

    test "change_dock_station/1 returns a dock_station changeset" do
      dock_station = dock_station_fixture()
      assert %Ecto.Changeset{} = Services.change_dock_station(dock_station)
    end
  end
end
