defmodule TartuSmarterBikeWeb.UserController do
  use TartuSmarterBikeWeb, :controller
  alias TartuSmarterBike.Repo
  alias TartuSmarterBike.Accounts.User
  alias TartuSmarterBike.Accounts.Payment

  def index(conn, _params) do
    redirect(conn, to: Routes.session_path(conn, :new))  ## ???? helpers?
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account created successfully")
        |> redirect(to: Routes.user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, %{})

    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    Repo.update(changeset)
    redirect(conn, to: Routes.user_path(conn, :index))
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully")
    |> redirect(to: Routes.user_path(conn, :index))
  end

end
