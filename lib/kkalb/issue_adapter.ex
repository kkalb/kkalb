defmodule Kkalb.IssueAdapter do
  @moduledoc """
  Template for issue queries for postgres and ets.
  """
  alias Kkalb.Issues.Issue

  @type t :: module

  @callback list_issues(NaiveDateTime.t()) :: [Issue.t()]
  @callback list_issues() :: [Issue.t()]
  @callback count_open_issues_before(NaiveDateTime.t()) :: non_neg_integer()
  @callback count_open_issues() :: non_neg_integer()
  @callback upsert_issue(map()) :: any()
  @callback upsert_issues(list()) :: non_neg_integer()
end
