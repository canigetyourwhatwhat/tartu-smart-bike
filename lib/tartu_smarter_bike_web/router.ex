defmodule TartuSmarterBikeWeb.Router do
  use TartuSmarterBikeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TartuSmarterBikeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug TartuSmarterBike.AuthPipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end



  scope "/", TartuSmarterBikeWeb do
    pipe_through [:browser]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/", TartuSmarterBikeWeb do
    pipe_through [:browser, :browser_auth]
    get "/", PageController, :index
    get "/account", PageController, :home
    get "/invoice", PageController, :invoice
    get "/membership_form", PageController, :membership_form
    post "/membership", PageController, :membership
    get "/prepaid_form", PageController, :prepaid_form
    post "/prepaid", PageController, :prepaid
    get "/gifting_form", PageController, :gifting_form
    post "/gifting", PageController, :gifting
    get "/map", PageController, :map
    post "/rides/report", RideController, :report
    post "/rides/unlock", RideController, :unlock
    post "/rides/book", RideController, :book
    get "/rides/report_form", RideController, :report_form
    post "/rides/arrived", RideController, :arrived
    get "/rides/arrived_form", RideController, :arrived_form
    get "/rides/complete", RideController, :complete_ride
    get "/rides/rankings", RideController, :ranking
    resources "/users", UserController
    resources "/rides", RideController

  end

  # Other scopes may use custom stacks.
  # scope "/api", TartuSmarterBikeWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TartuSmarterBikeWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
