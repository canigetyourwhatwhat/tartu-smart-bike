defmodule TartuSmarterBikeWeb.PageControllerTest do
  use TartuSmarterBikeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Log in"
  end
end
