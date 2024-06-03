defmodule Kkalb.Issues do
  @moduledoc """
  Context module for issues.
  """

  alias Kkalb.Issues.Issue
  # import Ecto.Query
  alias Kkalb.Repo

  @doc """
  Returns the list of issues.

  ## Examples

      iex> list_issues()
      [%Issue{}, ...]

  """
  def list_issues() do
    Repo.all(Issue)
  end

  @doc """
  Creates an issue.

  ## Examples

      iex> create_issue(%{id: 2328781667, number: 123, gh_created_at: "2024-06-01T12:00:00Z", gh_updated_at: "2024-06-01T13:00:00Z", gh_closed_at: "2024-06-01T14:00:00Z"})
      {:ok, %Issue{}}

      iex> create_issue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_issue(attrs \\ %{}) do
    %Issue{}
    |> Issue.changeset(attrs)
    |> Repo.insert()
  end
end
