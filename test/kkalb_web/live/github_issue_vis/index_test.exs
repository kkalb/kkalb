defmodule KkalbWeb.GithubIssueVis.IndexTest do
  use KkalbWeb.ConnCase, async: false

  test "renders canvas", %{conn: conn} do
    {:ok, _view, _html} = live(conn, "/live")
    # open_browser(view)
  end
end
