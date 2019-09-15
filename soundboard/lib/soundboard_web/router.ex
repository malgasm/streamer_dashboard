defmodule SoundboardWeb.Router do
  use SoundboardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api", SoundboardWeb do
    pipe_through :browser

    resources "/sounds", SoundsController
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SoundboardWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", SoundboardWeb do
  #   pipe_through :api
  # end
end
