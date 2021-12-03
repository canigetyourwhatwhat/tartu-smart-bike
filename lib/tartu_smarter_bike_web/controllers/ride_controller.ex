defmodule TartuSmarterBikeWeb.RideController do
  use TartuSmarterBikeWeb, :controller

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias TartuSmarterBike.Services
  alias TartuSmarterBike.Repo
  alias TartuSmarterBike.Services.{Ride, Dock_station, Report}
  alias TartuSmarterBike.Accounts.Bike
  alias TartuSmarterBike.Accounts.User



  def index(conn, _params) do
    query = from b in Bike,
                         join: r in Ride, on: b.id == r.bike_id, order_by: [desc: r.updated_at]
    query = from [b, r] in query,
                 select: {b.id_code, r}

    rides = Repo.all(query)

    render(conn, "index.html", rides: rides)
  end

  def new(conn, _params) do
    # Checking the time
    working_hour(conn)
    # If a user doesn't have a memberhsip
    membership_is_valid(conn)

    changeset = Services.change_ride(%Ride{})
    render(conn, "new.html", changeset: changeset)
  end

  def report_form(conn, _params) do
    changeset = Report.changeset(%Report{}, %{})
    user = TartuSmarterBike.Authentication.load_current_user(conn)
    query = from r in TartuSmarterBike.Services.Ride,
      where: r.status != "completed" and r.user_id == ^user.id, select: r
    ride = TartuSmarterBike.Repo.one(query)

    render(conn, "report.html", changeset: changeset, ride: ride)
  end

  def report(conn, %{"report" => params}) do
    user = TartuSmarterBike.Authentication.load_current_user(conn)
    query = from r in Ride, where: r.status != "completed" and r.user_id == ^user.id, select: r
    ride = Repo.one(query)

    case ride == nil do
      true ->
        query2 = from b in Bike, where: b.id_code == ^params["id_code"], select: b
        bike = Repo.one(query2)

        case bike == nil do
          true ->
            conn
            |> put_flash(:info, "Entered Bike ID is not valid")
            |> redirect(to: Routes.ride_path(conn, :report_form))
          false ->
            # Update bike to "due-off" state
            Bike.changeset(bike, %{}, :update)
            |> Changeset.put_change(:usage_status, "due-off")
            |> Repo.update

            # Insert Report object
            report_fields = %{title: params["title"]}
            Report.changeset(%Report{}, report_fields)
            |> Changeset.put_change(:description, params["description"])
            |> Changeset.put_change(:bike_id, bike.id)
            |> Changeset.put_change(:user_id, user.id)
            |> Repo.insert
        end
      false ->
        # Update bike to "due-off" state
        query2 = from b in Bike, where: b.id == ^params["id_code"], select: b
        bike = Repo.one(query2)

        Bike.changeset(bike, %{}, :update)
        |> Changeset.put_change(:usage_status, "due-off")
        |> Repo.update

        # Insert Report object
        report_fields = %{title: params["title"]}
        Report.changeset(%Report{}, report_fields)
        |> Changeset.put_change(:description, params["description"])
        |> Changeset.put_change(:bike_id, ride.bike_id)
        |> Changeset.put_change(:user_id, user.id)
        |> Repo.insert
    end

    conn
    |> put_flash(:info, "Thank you for reporting an issue!")
    |> redirect( to: Routes.page_path(conn, :index))
  end

  def arrived_form(conn, _params) do
    docks = Repo.all(from d in Dock_station, select: d)
    changeset = Services.change_ride(%Ride{})
    render(conn, "arrived.html", docks: docks, changeset: changeset)
  end

  def arrived(conn, %{"ride" => param}) do
    query2 = from d in Dock_station, where: d.address == ^param["destination"], select: d
    dock = Repo.one(query2)
    case dock.capacity == dock.available_bikes do
      true ->
        conn
        |> put_flash(:info, "The dock station is full! Please ride to another.")
        |> redirect(to: Routes.ride_path(conn, :arrived_form))
      false ->
        # Update the dock station that the bike is parked
        Dock_station.changeset(dock, %{})
        |> Changeset.put_change(:available_bikes, dock.available_bikes + 1)
        |> Repo.update
    end

    # Update the ride info
    user = TartuSmarterBike.Authentication.load_current_user(conn)
    query = from r in Ride, where: r.status != "completed" and r.user_id == ^user.id, select: r
    created_ride = Repo.one(query)

    Ride.changeset(created_ride, %{destination: param["destination"]})
    #|> Changeset.put_change(:destination, param["destination"])
    |> Repo.update

    redirect(conn, to: Routes.ride_path(conn, :complete_ride))
  end

  def book(conn, %{"id" => dock_id}) do
    #json(conn, %{id: dock_id})
    user = TartuSmarterBike.Authentication.load_current_user(conn)

    # Checking the time
    working_hour(conn)

    query2 = from r in Ride, where: r.status != "completed" and r.user_id  == ^user.id, select: r
    ride = Repo.one(query2)

    if (membership_is_valid(conn)) do
      if ride != nil do
        json(conn, %{message: "You already booked a bike!", type: "error" })
      else
        query_dock = from d in Dock_station, where: d.id  == ^dock_id, select: d
        dock = List.first(Repo.all(query_dock))
        if dock.available_bikes != 0 do
          query = from b in Bike, where: b.dock_station_id  == ^dock_id, select: b
          booking_bike = List.first(Repo.all(query))

          # Update the bike status
          Bike.changeset(booking_bike, %{}, :update)
          |> Changeset.put_change(:usage_status, "booked")
          |> Repo.update

          # Create Ride object
          created_ride = create(conn, booking_bike.id_code)

          # Update the Ride object
          Ride.changeset(created_ride, %{})
          |> Changeset.put_change(:status, "booked")
          |> Repo.update

          json(conn, %{message: "Booked the bike! Unlock #{booking_bike.id_code} to ride it.", type: "info" })
        else
          json(conn, %{message: "The dock station is empty! Please book from another.", type: "error" })
        end
      end

    else
      User.changeset(user, %{})
      |> Changeset.put_change(:subscription_type, "Expired")
      |> Repo.update
      json(conn, %{message: "You need to update your membership. Can't book now", type: "error" })
    end
  end

  def unlock(conn, %{"ride" => param}) do

    # Get the Ride and Bike objects
    user = TartuSmarterBike.Authentication.load_current_user(conn)
    query_ride = from r in Ride, where: r.user_id == ^user.id and r.status == "booked", select: r
    ride = Repo.one(query_ride)
    query = from b in Bike, where: b.id_code  == ^param["id_code"], select: b
    bike = Repo.one(query)

    case ride == nil do
      true -> # Unlock a Bike based on the id_code
        # Validate the id_code
        case bike == nil || bike.usage_status != "available" || bike.locking_status != "locked" do
          true ->
            conn
            |> put_flash(:info, "Entered Bike ID is not valid")
            |> render("new.html", changeset: Services.change_ride(%Ride{}))
          false ->
            # Update the bike status
            Bike.changeset(bike, %{}, :update)
            |> Changeset.put_change(:usage_status, "in-use")
            |> Changeset.put_change(:locking_status, "unlocked")
            |> Repo.update

            #create Ride object
            create(conn, param["id_code"])

            # Send notification of unlocking
            conn
            |> put_flash(:info, "Unlocked the bike! Enjoy your ride :)")
            |> redirect(to: Routes.page_path(conn, :index))
        end

      false -> # If there is a ride that has "booked" status

        # Validate the booked bike is same as the type id_code
        if bike.id != ride.bike_id do
          conn
          |> put_flash(:info, "Entered Bike ID differs from booked bike ID")
          |> render("new.html", changeset: Services.change_ride(%Ride{}))
        else

          # Update bike status
          query_bike = from r in Bike, where: r.id == ^ride.bike_id, select: r
          booked_bike = Repo.one(query_bike)

          Bike.changeset(booked_bike, %{}, :update)
          |> Changeset.put_change(:usage_status, "in-use")
          |> Changeset.put_change(:locking_status, "unlocked")
          |> Repo.update

          # Update ride status
          Ride.changeset(ride, %{})
          |> Changeset.put_change(:status, "on-going")
          |> Repo.update

          # Send notification of unlocking
          conn
          |> put_flash(:info, "Unlocked the bike! Enjoy your ride :)")
          |> redirect(to: Routes.page_path(conn, :index))
      end
    end
  end

  def create(conn, id_code) do

    # Get the bike object
    query = from b in Bike, where: b.id_code == ^id_code, select: b
    bike = Repo.one(query)

    # Update the dock station that the bike left
    query = from d in Dock_station, where: d.id == ^bike.dock_station_id, select: d
    dock = Repo.one(query)
    Dock_station.changeset(dock, %{})
    |> Changeset.put_change(:available_bikes, dock.available_bikes - 1)
    |> Repo.update

    # Create Ride object and store it in Database
    user = TartuSmarterBike.Authentication.load_current_user(conn) |> Repo.preload(:ride)
    result = Ride.changeset(%Ride{}, %{departure: dock.address})
    |> Changeset.put_change(:user, user)
    |> Changeset.put_change(:bike, bike)
    |> Repo.insert

    case result do
      {:ok, ride} -> ride
    end
  end


  def complete_ride(conn, _params) do

    # Get Bike, Ride and Dock_station object
    user = TartuSmarterBike.Authentication.load_current_user(conn)
    query = from r in Ride,
                 join: b in Bike, on: r.status != "completed" and r.user_id == ^user.id and b.id == r.bike_id,
                 select: {b, r}
    riding_bike = elem(List.first(Repo.all(query)), 0)
    created_ride = elem(List.first(Repo.all(query)), 1)
    query2 = from d in Dock_station, where: d.address == ^created_ride.destination, select: d
    arrived_dock = Repo.one(query2)

    # Get departure dock
    dep_query =  from d in Dock_station, where: d.address == ^created_ride.departure, select: d
    departure_dock = Repo.one(dep_query)


    ## distance magic
    new_distance = if departure_dock.address == arrived_dock.address do
      Enum.random(1_000..9_999)
    else
      round(
        Geocalc.distance_between(
          [departure_dock.latitude, departure_dock.longitude],
          [arrived_dock.latitude, arrived_dock.longitude]
        )
      )
    end



    # Update the status of Bike.
    # If the bike was reported, it remains off-duty status
    if riding_bike.usage_status == "due-off" do
      changeset = Bike.changeset(riding_bike, %{}, :update)
                  |> Changeset.put_change(:locking_status, "locked")
                  |> Changeset.put_change(:usage_status, "due-off")
                  |> Changeset.put_change(:dock_station_id, arrived_dock.id)
      Repo.update!(changeset)
    else
      changeset = Bike.changeset(riding_bike, %{}, :update)
                  |> Changeset.put_change(:locking_status, "locked")
                  |> Changeset.put_change(:usage_status, "available")
                  |> Changeset.put_change(:dock_station_id, arrived_dock.id)
      Repo.update!(changeset)
    end

    # Create Invoice object based on the riding time
    duration = Timex.diff(DateTime.utc_now, created_ride.inserted_at, :hour)
    cost =
      cond do
        duration < 1 -> 0
        not created_ride.reported and 5 <= duration and duration < 24 -> 80
        created_ride.reported and 5 <= duration and duration < 24 -> duration
        24 <= duration -> 2500
        true -> duration
      end

    if 5 < duration and not created_ride.reported do
      Bike.changeset(riding_bike, %{})
      |> Changeset.put_change(:usage_status, "due-off")
      |> Repo.update
    end

    # Update the Ride object
    {_, new_created_ride} =
      Ride.changeset(created_ride, %{})
      |> Changeset.put_change(:status, "completed")
      |> Changeset.put_change(:distance, new_distance)
      |> Changeset.put_change(:fee, cost)
      |> Repo.update


    render(conn, "complete.html", ride: new_created_ride, bike: riding_bike)
  end

  def show(conn, %{"id" => id}) do
    ride = Services.get_ride!(id)
    render(conn, "show.html", ride: ride)
  end

  def edit(conn, %{"id" => id}) do
    ride = Services.get_ride!(id)
    changeset = Services.change_ride(ride)
    render(conn, "edit.html", ride: ride, changeset: changeset)
  end

  def update(conn, %{"id" => id, "ride" => ride_params}) do
    ride = Services.get_ride!(id)

    case Services.update_ride(ride, ride_params) do
      {:ok, ride} ->
        conn
        |> put_flash(:info, "Ride updated successfully.")
        |> redirect(to: Routes.ride_path(conn, :show, ride))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", ride: ride, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ride = Services.get_ride!(id)
    {:ok, _ride} = Services.delete_ride(ride)

    conn
    |> put_flash(:info, "Ride deleted successfully.")
    |> redirect(to: Routes.ride_path(conn, :index))
  end

  def ranking(conn, _params) do
    query = from u in User,
                 join: r in Ride, on: u.id == r.user_id, group_by: u.name, order_by: [desc: sum(r.distance)]
    query = from [u, r] in query,
                 select: {u.name, sum(r.distance)}

    rankings = Repo.all(query)

    render(conn, "ranking.html", rankings: rankings)
  end


  defp membership_is_valid(conn) do
    user = TartuSmarterBike.Authentication.load_current_user(conn)
    if (user.subscription_type == nil || Timex.after?(Timex.today(), user.expiration_date) ) do
      # Update membership status of the user
      user = TartuSmarterBike.Authentication.load_current_user(conn)
      User.changeset(user, %{})
      |> Changeset.put_change(:expiration_date, nil)
      |> Changeset.put_change(:subscription_type, nil)
      |> Repo.update

      conn
      |> put_flash(:info, "You need to update your membership")
      |> redirect(to: Routes.page_path(conn, :membership_form))
    end
  end

  defp working_hour(conn) do
    {_, {hour, _, _}} = :calendar.local_time()
    if 0 < hour and hour < 5 do
      conn
      |> put_flash(:info, "Service is not available during this time period")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

end
