defmodule TartuSmarterBike.AuthPipeline do
  use Guardian.Plug.Pipeline,
      otp_app: :tartu_smarter_bike,
      error_handler: TartuSmarterBike.ErrorHandler,
      module: TartuSmarterBike.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  plug Guardian.Plug.LoadResource, allow_blank: true
end
