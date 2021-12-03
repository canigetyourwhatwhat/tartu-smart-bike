defmodule TartuSmarterBike.Services.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field :title, :string
    field :description, :string

    belongs_to :bike, TartuSmarterBike.Accounts.Bike
    belongs_to :user, TartuSmarterBike.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
