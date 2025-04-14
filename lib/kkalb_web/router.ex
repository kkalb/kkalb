defmodule KkalbWeb.Router do
  use KkalbWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KkalbWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_cookies
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KkalbWeb do
    pipe_through :browser
    live("/", Live.Home)

    live("/issues", Live.GithubIssueVis.Index)
    live("/gameoflife", Live.GameOfLife.Index)
    live("/bike", Live.Bike.Index)

    get "/download_portfolio", DownloadController, :download_portfolio
    get "/set_user_cookie/:user_id", UserCookieController, :set
  end

  live_session :default, on_mount: Kkalb.Hooks.AllowEctoSandbox do
  end
end
