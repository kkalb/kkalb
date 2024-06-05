defmodule Kkalb.Issues.IssuesTest do
  use Kkalb.RepoCase, async: true
  alias Kkalb.Issues

  test "seeded list_issues/1 returns 2 issues" do
    nv_start_date = ~N[2024-05-20 00:00:00.000000]
    start_date = DateTime.from_naive!(nv_start_date, "Etc/UTC")

    [issue_1, issue_2, issue_3, issue_4] = Issues.list_issues(nv_start_date)
    assert Date.compare(issue_1.gh_created_at, start_date) == :gt
    assert Date.compare(issue_2.gh_created_at, start_date) == :gt
    assert Date.compare(issue_3.gh_created_at, start_date) == :lt
    assert Date.compare(issue_3.gh_closed_at, start_date) == :gt
    assert Date.compare(issue_4.gh_created_at, start_date) == :lt
    assert Date.compare(issue_4.gh_closed_at, start_date) == :gt
  end

  test "count_open_issues_before/1 returns 2" do
    nv_start_date = ~N[2024-05-20 00:00:00.000000]
    assert 2 = Issues.count_open_issues_before(nv_start_date)
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
