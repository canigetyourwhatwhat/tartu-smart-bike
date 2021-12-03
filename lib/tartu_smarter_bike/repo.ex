defmodule TartuSmarterBike.Repo do
  use Ecto.Repo,
    otp_app: :tartu_smarter_bike,
    adapter: Ecto.Adapters.Postgres
end
