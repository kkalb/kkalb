defmodule Kkalb.Issues.IssuesTest do
  use Kkalb.RepoCase, async: true
  alias Kkalb.Issues

  test "seeded list_issues/0 returns issues" do
    [issue | _] = Issues.list_issues()
    assert %Issues.Issue{} = issue
  end

  test "count_open_issues/0 returns 1" do
    assert 1 = Issues.count_open_issues()
  end

  test "upsert_issue/1" do
    datetime = DateTime.now!("Etc/UTC") |> DateTime.truncate(:second)

    attrs = %{
      id: 1000,
      number: 2000,
      gh_created_at: DateTime.to_iso8601(datetime),
      gh_updated_at: datetime |> DateTime.add(60, :minute) |> DateTime.to_iso8601(),
      gh_closed_at: nil
    }

    {:ok, issue} =
      Issues.upsert_issue(attrs)

    assert issue.id == 1000
    assert issue.number == 2000
    assert issue.gh_created_at == datetime
    assert issue.gh_updated_at == DateTime.add(datetime, 60, :minute)
    refute issue.gh_closed_at
  end
end
