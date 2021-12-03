defmodule TartuSmarterBikeWeb.SessionController do
  use TartuSmarterBikeWeb, :controller

  alias TartuSmarterBike.Repo
  alias TartuSmarterBike.Accounts.User

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(
        conn,
        %{
          "session" => %{
            "email" => email,
            "password" => password
          }
        }
      ) do
    user = Repo.get_by(User, email: email)

    case TartuSmarterBike.Authentication.check_credentials(user, password) do
      {:ok, _} ->
        conn
        |> TartuSmarterBike.Authentication.login(user)
        |> put_flash(:info, "Welcome, #{user.name}!")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, :unauthorized_user} ->
        conn
        |> put_flash(:error, "Bad Credentials")
        |> render("new.html")
    end
  end


  def delete(conn, _params) do
    conn
    |> TartuSmarterBike.Authentication.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end


end
