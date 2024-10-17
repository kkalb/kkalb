defmodule KkalbWeb.Router do
  use KkalbWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KkalbWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KkalbWeb do
    pipe_through :browser
    live("/", Live.Home)

    live("/live", Live.GithubIssueVis.Index)
    live("/gameoflife", Live.GameOfLife.Index)

    get "/download_portfolio", DownloadController, :download_portfolio
  end
end
