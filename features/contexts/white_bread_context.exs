defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias TartuSmarterBike.Accounts.{User, Bike, Payment}
  alias TartuSmarterBike.Services.{Dock_station, Ride}
  alias TartuSmarterBike.Repo

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


  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end

  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(TartuSmarterBike.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(TartuSmarterBike.Repo, {:shared, self()})
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

    %{}
  end

  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(TartuSmarterBike.Repo)
    Hound.end_session
  end


  when_ ~r/^I go to Registration page$/, fn state ->
    navigate_to("/users/new")
    {:ok, state}
  end

  and_ ~r/^I input my name as "(?<name>[^"]+)", email "(?<email>[^"]+)", birthdate "(?<birthdate>[^"]+)", password "(?<password>[^"]+)"$/,
       fn state, %{name: name,email: email,birthdate: birthdate,password: password} ->

         fill_field({:id, "name"}, name)
         fill_field({:id, "email"}, email)
         fill_field({:id, "birthdate"}, birthdate)
         fill_field({:id, "password"}, password)
         {:ok, state}
       end

  and_ ~r/^I input payment_method as "(?<payment_method>[^"]+)", card_number "(?<card_number>[^"]+)", subscription_type "(?<subscription_type>[^"]+)"$/,
       fn state, %{payment_method: payment_method, card_number: card_number, subscription_type: subscription_type} ->

         find_element(:css, "#payment_method_type option[value='#{payment_method}']") |> click()
         fill_field({:id, "card_number"}, card_number)
         find_element(:css, "#subscription_type option[value='#{subscription_type}']") |> click()

         {:ok, state}
       end

  and_ ~r/^I click Register$/, fn state ->
    click({:id, "submit_register"})
    {:ok, state}
  end

  then_ ~r/^I get a message as "(?<message>[^"]+)"$/, fn state, %{message: message} ->
    assert visible_in_page? ~r/#{message}/
    {:ok, state}
  end

  then_ ~r/^I get an error message/, fn state ->
    assert visible_in_page? ~r/Oops, something went wrong! Please check the errors below./
    {:ok, state}
  end

  and_ ~r/^I go to Login page$/, fn state ->
    navigate_to("/sessions/new")
    {:ok, state}
  end

  and_ ~r/^I input my email as "(?<email>[^"]+)" and password "(?<password>[^"]+)"$/,
       fn state, %{email: email, password: password} ->

         fill_field({:id, "session_email"}, email)
         fill_field({:id, "session_password"}, password)
         {:ok, state}

       end

  and_ ~r/^I click Login$/, fn state ->
    click({:id, "submit"})
    {:ok, state}
  end

  then_ ~r/^I get a success message as "Welcome, (?<name>[^"]+)!"$/, fn state,  %{name: name}->
    assert visible_in_page? ~r/Welcome, #{name}!/
    {:ok, state}
  end

  then_ ~r/^I get a fail message/, fn state ->
    assert visible_in_page? ~r/Bad Credentials/
    {:ok, state}
  end

  and_ ~r/^I click Logout$/, fn state ->
    click({:id, "logout"})
    {:ok, state}
  end

  and_ ~r/^I submit/, fn state ->
    click({:tag, "button"})
    {:ok, state}
  end

  then_ ~r/^I logged out/, fn state ->
    assert visible_in_page? ~r/Log in/
    {:ok, state}
  end

  when_ ~r/^I log in/, fn state ->
    navigate_to("/sessions/new")
    fill_field({:id, "session_email"}, "adil@gmail.com")
    fill_field({:id, "session_password"}, "adil123")
    {:ok, state}
  end

  and_ ~r/^I click on "(?<link>[^"]+)"$/, fn state,  %{link: link} ->
    click({:link_text, link})
    {:ok, state}
  end

  and_ ~r/^I select destination as "(?<destination>[^"]+)"$/, fn state, %{destination: destination} ->
    find_element(:css, "#destination option[value='#{destination}']") |> click()
    {:ok, state}
  end

  and_ ~r/^I add title as "(?<title>[^"]+)", description as "(?<description>[^"]+)", and id as "(?<id>[^"]+)"$/,
    fn state, %{description: description, title: title, id: id} ->

    fill_field({:id, "report_id_code"}, id)
    fill_field({:id, "description"}, description)
    fill_field({:id, "title"}, title)
    {:ok, state}
  end

  and_ ~r/^I add bike id as "(?<id>[^"]+)"$/,
    fn state, %{id: id} ->

    fill_field({:id, "ride_id_code"}, id)
    {:ok, state}
  end

  and_ ~r/^I go to Report an issue page$/, fn state ->
    navigate_to("/rides/report_form")
    {:ok, state}
  end

  and_ ~r/^I start typing "(?<dockstation>[^"]+)"$/,
    fn state, %{dockstation: dockstation} ->

    fill_field({:id, "map-search-box"}, dockstation)
    {:ok, state}
  end

  and_ ~r/^I book a bike$/, fn state ->
    execute_script("ajax_create_booking(arguments[0]); let start = new Date().getTime(); for (let i=0; i < 1e7; i++){if ((new Date().getTime() - start) > 5000){break;}}", ["73"])
    {:ok, state}
  end

  then_ ~r/^I get a successful booking message/, fn state ->
    assert visible_in_page? ~r/Cool/
    {:ok, state}
  end

  and_ ~r/^I click on Cool$/, fn state ->
    click({:class, "swal2-confirm"})
    {:ok, state}
  end
end
