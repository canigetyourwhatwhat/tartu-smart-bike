defmodule TartuSmarterBikeWeb.UserControllerTest do
  use TartuSmarterBikeWeb.ConnCase

  @valid_user %{
    name: "Adil Shirinov",
    password: "adil123",
    birthdate: ~D[1999-02-12],
    email: "adil@gmail.com",
    balance: 0.0,
    subscription_type: "1-year membership",
    payment: %{type: "Tartu Bus Card", card_number: "123456789" }
  }
  @existing_user %{
    name: "Adil Shirinov",
    password: "adil123",
    birthdate: ~D[1999-02-12],
    email: "adil@gmail.com",
    balance: 0.0,
    subscription_type: "1-year membership",
    payment: %{type: "Tartu Bus Card", card_number: "123456789" }
  }
  @invalid_user %{
    name: "Adil Shirinov",
    password: "adil123",
    birthdate: ~D[1999-02-12],
    email: nil,
    balance: 0.0,
    subscription_type: "1-year membership",
    payment: %{type: "Tartu Bus Card", card_number: "123456789" }
  }

  describe "User Registration" do
    test "Registers a user with valid input data", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @valid_user)
      assert html_response(conn, 302) =~ ~r/redirected/
    end

    test "Return error in case of invalid input data", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_user)
      assert html_response(conn, 200) =~ ~r/can&#39;t be blank/
    end

    test "Return error if a user with the given email exists", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @existing_user)
      conn = post(conn, Routes.user_path(conn, :create), user: @existing_user)
      assert html_response(conn, 200) =~ ~r/has already been taken/
    end
  end
end