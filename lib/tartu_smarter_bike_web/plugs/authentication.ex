defmodule TartuSmarterBike.Authentication do

  import Plug.Conn
  alias TartuSmarterBike.Guardian

  def check_credentials(user, password) do
    IO.inspect(user)
    if user && user.password == password do
      {:ok, user}
    else
      {:error, :unauthorized_user}
    end
  end


  def login(conn, user) do
    conn |> Guardian.Plug.sign_in(user)
  end

  def logout(conn) do
    conn |> Guardian.Plug.sign_out()
  end

  def load_current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end

end
