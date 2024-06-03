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

      iex> list_issues()
      [%Issue{}, ...]

  """
  def list_issues(_from_date \\ ~U[2024-01-01 00:00:00Z]) do
    query =
      from(i in Issue,
        order_by: [desc: i.gh_created_at]
        # where: i.gh_created_at >= ^from_date
      )

    Repo.all(query)
  end

  @doc """
  Creates an issue.

  ## Examples

      iex> upsert_issue(%{id: 2328781667, number: 123, gh_created_at: "2024-06-01T12:00:00Z", gh_updated_at: "2024-06-01T13:00:00Z", gh_closed_at: "2024-06-01T14:00:00Z"})
      {:ok, %Issue{}}

      iex> upsert_issue(%{field: bad_value})
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
