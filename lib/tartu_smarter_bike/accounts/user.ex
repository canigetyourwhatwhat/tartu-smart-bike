defmodule TartuSmarterBike.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @mail_regex ~r/^[A-Za-z0-9.%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}$/

  schema "users" do
    field :balance, :float, default: 0.0
    field :birthdate, :date
    field :email, :string
    field :name, :string
    field :password, :string
    field :subscription_type, :string
    field :card_number, :string
    field :expiration_date, :utc_datetime


    has_many :ride, TartuSmarterBike.Services.Ride
    has_one :report, TartuSmarterBike.Services.Report
    has_one :membership_invoice, TartuSmarterBike.Services.Membership_Invoice
    has_one :ride_invoice, TartuSmarterBike.Services.Ride_Invoice
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :name, :birthdate, :email, :password, :balance, :card_number, :subscription_type])
    |> cast_assoc(:ride, on_replace: :update)
    |> validate_required([:name, :birthdate, :email, :password, :balance, :card_number])
    |> unique_constraint(:email)
    |> validate_format(:email, @mail_regex)
    |> validate_length(:password, min: 6)
    |> validate_length(:card_number, min: 16, max: 16)
  end
end
