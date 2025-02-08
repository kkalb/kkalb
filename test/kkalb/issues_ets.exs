defmodule Kkalb.IssuesEtsTest do
  use ExUnit.Case, async: true

  alias Kkalb.Issues.Issue
  alias Kkalb.IssuesEts

  setup do
    issues = [
      %Issue{
        id: 1,
        number: 123,
        gh_created_at: ~N[2024-01-01 00:00:00],
        gh_updated_at: ~N[2024-01-02 00:00:00],
        gh_closed_at: ~N[2024-01-03 00:00:00]
      },
      %Issue{
        id: 2,
        number: 124,
        gh_created_at: ~N[2024-01-02 00:00:00],
        gh_updated_at: ~N[2024-01-03 00:00:00],
        gh_closed_at: nil
      },
      %Issue{
        id: 3,
        number: 125,
        gh_created_at: ~N[2024-01-03 00:00:00],
        gh_updated_at: ~N[2024-01-04 00:00:00],
        gh_closed_at: nil
      }
    ]

    Enum.each(issues, fn issue ->
      Kkalb.EtsIssuesGenServer.insert({issue.id, issue})
    end)

    :ok
  end

  test "list_issues/1 filters and sorts issues correctly" do
    start_date = ~N[2024-01-02 00:00:00]

    result = IssuesEts.list_issues(start_date)

    # Issue with id 1 should be included because it was closed after the start_date
    # Issue with id 2 should be included because it's open and after the start_date
    # Issue with id 3 should be included because it's open and after the start_date
    assert length(result) == 3

    # Assert the issues are sorted by gh_created_at in descending order
    assert Enum.at(result, 0).id == 3
    assert Enum.at(result, 1).id == 2
    assert Enum.at(result, 2).id == 1
  end
end
