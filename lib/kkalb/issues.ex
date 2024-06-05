defmodule Kkalb.Issues do
  @moduledoc """
  Context module for issues.
  """

  alias Kkalb.Issues.Issue
  import Ecto.Query
  alias Kkalb.Repo

  @doc """
  Returns the list of issues.

  ## Examples

      iex> Issues.list_issues()
      [%Issues.Issue{}}

  """
  @spec list_issues(NaiveDateTime.t()) :: [%Issue{}]
  def list_issues(start_date) do
    query =
      from(i in Issue,
        order_by: [desc: i.gh_created_at],
        where: i.gh_created_at >= ^start_date or i.gh_closed_at >= ^start_date
      )

    Repo.all(query)
  end

  @spec list_issues() :: [%Issue{}]
  def list_issues() do
    query =
      from(i in Issue,
        order_by: [desc: i.gh_created_at]
      )

    Repo.all(query)
  end

  @doc """
  Returns the amount of issues that are not closed before end_date.

  ## Examples

      iex> Issues.count_open_issues(~N[2024-06-01 00:00:00])
      [%Issues.Issue{}]

  """
  @spec count_open_issues_before(NaiveDateTime.t()) :: non_neg_integer()
  def count_open_issues_before(end_date) do
    query =
      from(i in Issue,
        where: is_nil(i.gh_closed_at),
        where: i.gh_created_at < ^end_date
      )

    Repo.aggregate(query, :count)
  end

  @spec count_open_issues() :: non_neg_integer()
  def count_open_issues() do
    query = from(i in Issue, where: is_nil(i.gh_closed_at))

    Repo.aggregate(query, :count)
  end

  @doc """
  Creates an issue.

  ## Examples

      iex> Issues.upsert_issue(%{id: 2328781667, number: 123, gh_created_at: "2024-06-01T12:00:00Z", gh_updated_at: "2024-06-01T13:00:00Z", gh_closed_at: "2024-06-01T14:00:00Z"})
      {:ok, %Issues.Issue{}}

      iex> Issues.upsert_issue(%{field: ""})
      {:error, %Ecto.Changeset{}}

  """
  def upsert_issue(attrs) do
    gh_created_at = attrs.gh_created_at && DateTime.from_iso8601(attrs.gh_created_at) |> elem(1)
    gh_updated_at = attrs.gh_updated_at && DateTime.from_iso8601(attrs.gh_updated_at) |> elem(1)
    gh_closed_at = attrs.gh_closed_at && DateTime.from_iso8601(attrs.gh_closed_at) |> elem(1)

    issue = %Issue{
      id: attrs.id,
      number: attrs.number,
      gh_created_at: gh_created_at,
      gh_updated_at: gh_updated_at,
      gh_closed_at: gh_closed_at
    }

    Repo.insert(
      issue,
      on_conflict: [
        set: [gh_updated_at: gh_updated_at, gh_closed_at: gh_closed_at]
      ],
      conflict_target: :id
    )
  end
end
