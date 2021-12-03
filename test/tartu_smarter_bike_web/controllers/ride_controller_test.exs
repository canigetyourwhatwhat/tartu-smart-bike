defmodule TartuSmarterBikeWeb.RideControllerTest do
  use TartuSmarterBikeWeb.ConnCase
  alias TartuSmarterBike.Accounts.{User, Bike, Payment}
  alias TartuSmarterBike.Services.Dock_station
  alias TartuSmarterBike.Services.Ride
  alias TartuSmarterBike.Repo
  alias TartuSmarterBike.Guardian

  import TartuSmarterBike.ServicesFixtures

  @valid_payment %Payment{
    type: "Tartu Bus Card",
    card_number: "123456789"
  }

  @valid_dock_station %Dock_station{
    address: "some address",
    longitude: 1.0,
    latitude: 1.0,
    capacity: 10,
    available_bikes: 5
  }

  setup do
    payment = Repo.insert!(@valid_payment)

    valid_user = %User{
      name: "Adil Shirinov",
      password: "adil123",
      birthdate: ~D[1999-02-12],
      email: "adil@gmail.com",
      balance: 0.0,
      subscription_type: "1-year membership",
      payment: payment
    }

    user = Repo.insert!(valid_user)

    dock = Repo.insert!(@valid_dock_station)

    valid_bike = %Bike{
      id_code: "1",
      usage_status: "available",
      locking_status: "locked",
      type: "normal",
      dock_station: dock
    }

    bike = Repo.insert!(valid_bike)
    conn = build_conn()
           |> bypass_through(TartuSmarterBike.Router, [:browser, :browser_auth, :ensure_auth])
           |> get("/")
           |> Map.update!(:state, fn (_) -> :set end)
           |> Guardian.Plug.sign_in(user)
           |> send_resp(200, "Flush the session")
           |> recycle
    {:ok, conn: conn}
  end

  describe "Ride" do
    test "Start a ride", %{conn: conn}do
      conn = post(conn, Routes.ride_path(conn, :unlock), ride: %{id_code: "19147"})
      conn = get conn, redirected_to(conn)
      assert html_response(conn, 200) =~ ~r/Unlocked the bike! Enjoy your ride/
    end

    test "Finish the ride", %{conn: conn} do
      conn = post(conn, Routes.ride_path(conn, :unlock), ride: %{id_code: "19147"})
      conn = get conn, redirected_to(conn)
      conn = post(conn, Routes.ride_path(conn, :arrived), ride: %{destination: "Delta"})
      conn = get conn, redirected_to(conn)
      assert html_response(conn, 200) =~ ~r/Ride information/
    end
  end

  describe "Ride History" do
    test "Get Ride History", %{conn: conn} do
      conn = post(conn, Routes.ride_path(conn, :unlock), ride: %{id_code: "19147"})
      conn = get conn, redirected_to(conn)
      conn = post(conn, Routes.ride_path(conn, :arrived), ride: %{destination: "Delta"})
      conn = get conn, redirected_to(conn)
      ride = Repo.get_by(Ride, status: "completed")
      conn = get(conn, "/rides")

      assert ride.destination == "Delta"
      assert ride.departure == "Karete"
      assert html_response(conn, 200) =~ ~r/Delta/
    end
  end


  describe "Issue Reporting" do
    test "Report during ride", %{conn: conn} do
      conn = post(conn, Routes.ride_path(conn, :unlock), ride: %{id_code: "19147"})
      conn = get conn, redirected_to(conn)
      conn = post(conn, Routes.ride_path(conn, :report), report: %{
        title: "some title",
        description: "some description"
        })
      conn = get conn, redirected_to(conn)
      assert html_response(conn, 200) =~ ~r/Thank you for reporting an issue!/
    end

    test "Report after the ride", %{conn: conn} do
      conn = post(conn, Routes.ride_path(conn, :unlock), ride: %{id_code: "19147"})
      conn = get conn, redirected_to(conn)
      conn = post(conn, Routes.ride_path(conn, :arrived), ride: %{destination: "Delta"})
      conn = get conn, redirected_to(conn)
      conn = post(conn, Routes.ride_path(conn, :report), report: %{
        id_code: "19147",
        title: "some title",
        description: "some description"
        })
      conn = get conn, redirected_to(conn)
      assert html_response(conn, 200) =~ ~r/Thank you for reporting an issue!/
    end
  end

  describe "Bike booking" do
    test "Book a bike from available", %{conn: conn} do
      conn = post(conn, Routes.ride_path(conn, :book), id: 73)
      body = json_response(conn, 200)
      assert body["message"] =~ ~r/Booked the bike/
      conn = post(conn, Routes.ride_path(conn, :unlock), ride: %{id_code: "63936"})
      conn = get conn, redirected_to(conn)
      assert html_response(conn, 200) =~ ~r/Unlocked the bike!/
    end

    test "Book a bike from empty dock station", %{conn: conn} do
      conn = post(conn, Routes.ride_path(conn, :book), id: 80)
      body = json_response(conn, 200)
      assert "The dock station is empty! Please book from another." == body["message"]
    end

    test "Book after booking", %{conn: conn} do
      conn = post(conn, Routes.ride_path(conn, :book), id: 73)
      conn = post(conn, Routes.ride_path(conn, :book), id: 87)
      body = json_response(conn, 200)
      assert "You already booked a bike!" == body["message"]
    end

    test "Unlock not booked", %{conn: conn} do
      conn = post(conn, Routes.ride_path(conn, :book), id: 73)
      conn = post(conn, Routes.ride_path(conn, :unlock), ride: %{id_code: "1"})
      assert html_response(conn, 200) =~ ~r/Entered Bike ID differs from booked bike ID/
    end
  end
end
