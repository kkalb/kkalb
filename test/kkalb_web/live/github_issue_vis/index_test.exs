defmodule KkalbWeb.GithubIssueVis.IndexTest do
  use KkalbWeb.FeatureCase, async: false

  feature "User visits the homepage", %{session: session} do
    IO.inspect(session)

    session
    |> visit("/")
    |> assert_text("Welcome to Phoenix!")
  end
end
