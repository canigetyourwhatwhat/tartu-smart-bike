ExUnit.start()
ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
Ecto.Adapters.SQL.Sandbox.mode(TartuSmarterBike.Repo, :manual)
