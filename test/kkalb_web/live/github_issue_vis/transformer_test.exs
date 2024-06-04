defmodule KkalbWeb.Live.TransformerTest do
  use Kkalb.RepoCase, async: false

  alias KkalbWeb.Live.GithubIssueVis.Transformer
  alias Kkalb.Issues

  test "transformer transforms properly" do
    assert 5 == Issues.list_issues() |> length()
  end
end
