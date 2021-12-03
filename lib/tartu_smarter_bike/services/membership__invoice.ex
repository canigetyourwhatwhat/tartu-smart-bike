defmodule TartuSmarterBike.Services.Membership_Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  @list ["1-year membership", "1-week membership", "1-day membership", "1-hour membership"]

  schema "membership_invoices" do
    field :amount, :integer
    field :membership, :string

    belongs_to :user, TartuSmarterBike.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(membership__invoice, attrs) do
    membership__invoice
    |> cast(attrs, [:amount])
    |> validate_inclusion(:membership, @list)
    |> validate_required([:amount])
  end
end
