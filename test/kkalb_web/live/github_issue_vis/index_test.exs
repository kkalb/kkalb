defmodule KkalbWeb.GithubIssueVis.IndexTest do
  use KkalbWeb.ConnCase, async: false

  test "renders canvas", %{conn: conn} do
    {:ok, view, html} = live(conn, "/live")
    IO.inspect(html)
    # open_browser(view)
  end
end
