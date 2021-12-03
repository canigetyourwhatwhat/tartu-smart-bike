defmodule TartuSmarterBikeWeb.PageController do
  use TartuSmarterBikeWeb, :controller

  import Ecto.Query, only: [from: 2]
  alias TartuSmarterBike.Accounts.{Bike, User}
  alias TartuSmarterBike.Services.{Ride, Membership_Invoice, Prepaid_Card}
  alias TartuSmarterBike.Repo
  alias Ecto.Changeset


  def index(conn, _params) do
    user = TartuSmarterBike.Authentication.load_current_user(conn)

    case user == nil do
      true ->
        render(conn, "index.html", ride: %{})

      false ->
        query = from r in Ride, where: r.status != "completed" and r.user_id == ^user.id, select: r
        ride = Repo.one(query)
        if ride == nil do
          render(conn, "index.html", ride: ride, bike: nil)
        else
          query2 = from b in Bike, where: b.id == ^ride.bike_id, select: b
          bike = Repo.one(query2)
          render(conn, "index.html", ride: ride, bike: bike)
        end


    end
  end

  def home(conn, _params) do
    user = TartuSmarterBike.Authentication.load_current_user(conn)
    render(conn, "account.html", user: user)
  end


  def map(conn, _params) do
    query = from d in TartuSmarterBike.Services.Dock_station, select: d
    bike_q = from b in TartuSmarterBike.Accounts.Bike,
      where: b.usage_status == "available" and b.locking_status == "locked",
      select: b
    stations = TartuSmarterBike.Repo.all(query)
    bikes = TartuSmarterBike.Repo.all(bike_q)
    render(conn, "map.html", stations: stations, bikes: bikes)
  end


  def prepaid_form(conn, _params) do
    changeset = Prepaid_Card.changeset(%Prepaid_Card{}, %{})
    render(conn, "prepaid.html", changeset: changeset)
  end

  def prepaid(conn, %{"prepaid__card" => param}) do
    prepaid_number = param["prepaid_card_number"]
    query = from p in TartuSmarterBike.Services.Prepaid_Card,
                 where: p.number == ^prepaid_number and p.used == false, select: p
    prepaid_card = Repo.one(query)

    case prepaid_card == nil do
      true ->
        conn
        |> put_flash(:info, "Entered prepaid card is invalid or has been used.")
        |> redirect(to: Routes.page_path(conn, :prepaid_form))
      false ->
        user = TartuSmarterBike.Authentication.load_current_user(conn)
        new_balance = user.balance + prepaid_card.value

        # Add card's value to balance
        User.changeset(user, %{})
        |> Changeset.put_change(:balance, new_balance)
        |> Repo.update

        # Set card as used
        Prepaid_Card.changeset(prepaid_card, %{})
        |> Changeset.put_change(:used, true)
        |> Repo.update
    end
      redirect(conn, to: Routes.page_path(conn, :home))
  end


  def membership_form(conn, _params) do
    changeset = Membership_Invoice.changeset(%Membership_Invoice{}, %{})
    render(conn, "membership.html", changeset: changeset)
  end

  def membership(conn, %{"membership__invoice" => param}) do
    exp_date_map = %{"1-year membership" => 365, "1-week membership" => 7, "1-day membership" => 1, "1-hour membership" => 0 }
    cost =
      case param["subscription_type"] do
        "1-year membership" -> 30
        "1-week membership" -> 10
        "1-day membership"  -> 5
        "1-hour membership" -> 2
      end


    user = TartuSmarterBike.Authentication.load_current_user(conn)

    # if user has enough money on balance

    if(user.balance >= cost) do
      User.changeset(user, %{})
      |> Changeset.put_change(:balance, user.balance - cost)
      |> Changeset.put_change(:subscription_type, param["subscription_type"])
      |> Repo.update

      if(exp_date_map[param["subscription_type"]] == 0) do
        exp_date = Timex.shift(Timex.now(), hours: 1) |> DateTime.truncate(:second)
        User.changeset(user, %{})
        |> Changeset.put_change(:expiration_date, exp_date)
        |> Repo.update
      else
        days = exp_date_map[param["subscription_type"]]
        exp_date = Timex.shift(Timex.now(), days: days) |> DateTime.truncate(:second)
        User.changeset(user, %{})
        |> Changeset.put_change(:expiration_date, exp_date)
        |> Repo.update
      end

      Membership_Invoice.changeset(%Membership_Invoice{}, %{amount: cost})
      |> Changeset.put_change(:user_id, user.id)
      |> Changeset.put_change(:membership, param["subscription_type"])
      |> Repo.insert
      redirect(conn, to: Routes.page_path(conn, :home))
    else # imitate the subtraction from the credit card
      Membership_Invoice.changeset(%Membership_Invoice{}, %{amount: cost})
      |> Changeset.put_change(:user_id, user.id)
      |> Changeset.put_change(:membership, param["subscription_type"])
      |> Repo.insert

      User.changeset(user, %{})
      |> Changeset.put_change(:subscription_type, param["subscription_type"])
      |> Repo.update

      if(exp_date_map[param["subscription_type"]] == 0) do
        exp_date = Timex.shift(Timex.now(), hours: 1) |> DateTime.truncate(:second)
        User.changeset(user, %{})
        |> Changeset.put_change(:expiration_date, exp_date)
        |> Repo.update
      else
        days = exp_date_map[param["subscription_type"]]
        exp_date = Timex.shift(Timex.now(), days: days) |> DateTime.truncate(:second)
        User.changeset(user, %{})
        |> Changeset.put_change(:expiration_date, exp_date)
        |> Repo.update
      end

      conn
      |> put_flash(:info, "You don't have enough balance. We subtracted #{cost} euros from your credit card")
      |> redirect(to: Routes.page_path(conn, :home))
    end

  end




  def gifting_form(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "gifting.html", changeset: changeset)
  end

  def gifting(conn, %{"user" => param}) do
    gifting_user = param["gifting_user_email"]

    query = from u in TartuSmarterBike.Accounts.User,
                 where: u.email == ^gifting_user, select: u
    gifting_user = Repo.one(query)
    exp_date_map = %{"1-year membership" => 365, "1-week membership" => 7, "1-day membership" => 1, "1-hour membership" => 0 }
    gifting_membership = exp_date_map[param["subscription_type"]]

    case gifting_user == nil do
      true ->
        conn
        |> put_flash(:info, "User doesn't exists")
        |> redirect(to: Routes.page_path(conn, :gifting_form))
      false ->
          if (gifting_user.subscription_type != nil) do
            if (gifting_membership == 0) do
              if(Timex.after?(Timex.shift(Timex.today(), hours: 1), gifting_user.expiration_date)) do
                User.changeset(gifting_user, %{})
                |> Changeset.put_change(:subscription_type, param["subscription_type"])
                |> Changeset.put_change(:expiration_date, Timex.shift(DateTime.utc_now(), hours: 1)|> DateTime.truncate(:second))
                |> Repo.update
                conn
                |> put_flash(:info, "Success")
                |> redirect(to: Routes.page_path(conn, :gifting_form))
                # add money subtraction from sender
              else
                conn
                |> put_flash(:info, "User already has a fresh membership")
                |> redirect(to: Routes.page_path(conn, :gifting_form))
              end
            else
              days = exp_date_map[param["subscription_type"]]
              IO.inspect(gifting_user)
              if(Timex.after?(Timex.shift(Timex.today(), days: days), gifting_user.expiration_date)) do
                User.changeset(gifting_user, %{})
                |> Changeset.put_change(:subscription_type, param["subscription_type"])
                |> Changeset.put_change(:expiration_date,  Timex.shift(DateTime.utc_now(), days: days)|> DateTime.truncate(:second))
                |> Repo.update
                conn
                |> put_flash(:info, "Success")
                |> redirect(to: Routes.page_path(conn, :gifting_form))
                # add money subtraction from sender
              else
                conn
                |> put_flash(:info, "User already has a fresh membership")
                |> redirect(to: Routes.page_path(conn, :gifting_form))
              end
            end
          else
              if (gifting_membership == 0) do
                  User.changeset(gifting_user, %{})
                  |> Changeset.put_change(:subscription_type, param["subscription_type"])
                  |> Changeset.put_change(:expiration_date, Timex.shift(DateTime.utc_now(), hours: 1)|> DateTime.truncate(:second))
                  |> Repo.update
                  conn
                  |> put_flash(:info, "Success")
                  |> redirect(to: Routes.page_path(conn, :gifting_form))
              else
                days = exp_date_map[param["subscription_type"]]
                User.changeset(gifting_user, %{})
                |> Changeset.put_change(:subscription_type, param["subscription_type"])
                |> Changeset.put_change(:expiration_date, Timex.shift(DateTime.utc_now(), days: days)|> DateTime.truncate(:second))
                |> Repo.update
                conn
                |> put_flash(:info, "Success")
                |> redirect(to: Routes.page_path(conn, :gifting_form))
              end
          end
    end
  end

end