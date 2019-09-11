defmodule FrontmanWeb.Router do
  use FrontmanWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug Frontman.UserManager.Pipeline
    plug FrontmanWeb.Plug.AssignCurrentUser
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  # Maybe logged in routes
  scope "/", FrontmanWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index

    get "/login", SessionController, :new
    post "/login", SessionController, :login
    get "/logout", SessionController, :logout
  end

  # Definitely logged in scope
  scope "/", FrontmanWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    resources "/feeds", FeedController
  end
end
