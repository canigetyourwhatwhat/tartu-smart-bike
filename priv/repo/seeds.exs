# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TartuSmarterBike.Repo.insert!(%TartuSmarterBike.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TartuSmarterBike.{Repo, Accounts.User, Accounts.Bike, Services.Dock_station, Services.Prepaid_Card}
import Ecto.Query, only: [from: 2]

alias TartuSmarterBike.Repo

[%{balance: 10.0, birthdate: ~D[1999-02-12], name: "Fred", email: "fred@gmail.com", password: "parool", subscription_type: "1-year membership", card_number: "1234567890123456"}]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)


# Insert Dock station data
File.stream!("./dockstations_map.csv")
|> CSV.decode(headers: true)
|> Enum.map(fn (item) ->
  {:ok, fields} = item
  required_item = Map.take(fields, ["name", "lat", "lon", "total_docks"])
  Dock_station.changeset(%Dock_station{}, %{address: required_item["name"], longitude: required_item["lat"], latitude: required_item["lon"], capacity: required_item["total_docks"], available_bikes: 0})
  |> Repo.insert
  end)

# Insert Bike data
File.stream!("./new2_bikes.csv")
|> CSV.decode(headers: true)
|> Enum.map(fn (item) ->
  {:ok, fields} = item
  required_item = Map.take(fields, ["id_code", "usage_status", "type", "locking_status", "station_id"])
  query = from d in Dock_station, where: d.id == ^required_item["station_id"], select: d
  dock = Repo.one(query)
  bikechangeset = Bike.changeset(%Bike{}, %{id_code: required_item["id_code"], locking_status: required_item["locking_status"], usage_status: required_item["usage_status"], type: required_item["type"], dock_station_id: dock.id}, :insert)
  |> Repo.insert
  end)


# Insert some prepaid cards
File.stream!("./prepaid_cards.csv")
|> CSV.decode(headers: true)
|> Enum.map(fn (item) ->
  {:ok, fields} = item
  required_item = Map.take(fields, ["number", "used", "value"])
  Prepaid_Card.changeset(%Prepaid_Card{}, %{number: required_item["number"], used: required_item["used"], value: required_item["value"]})
  |> Repo.insert
end)