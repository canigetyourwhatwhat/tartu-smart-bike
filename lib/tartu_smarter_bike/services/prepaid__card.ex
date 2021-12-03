defmodule TartuSmarterBike.Services.Prepaid_Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prepaid_cards" do
    field :number, :string
    field :used, :boolean, default: false
    field :value, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(prepaid__card, attrs) do
    prepaid__card
    |> cast(attrs, [:number, :used, :value])
    |> validate_required([:number])
    |> validate_number(:value, greater_than: 0, message: "Prepaid card's value must be > 0")


  end
end
