defmodule Kkalb.IssuesEts do
  @moduledoc """
  Context module for issues for ets table without DB.
  """

  @behaviour Kkalb.IssueAdapter

  alias Kkalb.EtsIssuesGenServer
  alias Kkalb.Issues.Issue

  @doc """
  Returns the list of issues.

  ## Examples

      iex> Issues.list_issues()
      [%Issues.Issue{}}

  """
  @spec list_issues(NaiveDateTime.t()) :: [Issue.t()]
  def list_issues(start_date) do
    EtsIssuesGenServer.list()
    |> Enum.map(fn {_id, i} -> i end)
    |> Enum.filter(fn i ->
      NaiveDateTime.after?(i.gh_created_at, start_date) or is_nil(i.gh_closed_at) or
        NaiveDateTime.after?(i.gh_closed_at, start_date)
    end)
    |> Enum.sort_by(fn i -> i.gh_created_at end, :desc)
    |> Enum.map(fn i ->
      %Issue{
        id: i.id,
        number: i.number,
        gh_created_at: i.gh_created_at,
        gh_updated_at: i.gh_updated_at,
        gh_closed_at: i.gh_closed_at
      }
    end)
  end

  @spec list_issues() :: [Issue.t()]
  def list_issues do
    EtsIssuesGenServer.list()
    |> Enum.map(fn {_id, i} -> i end)
    |> Enum.sort_by(fn i -> i.gh_created_at end, :desc)
    |> Enum.map(fn i ->
      %Issue{
        id: i.id,
        number: i.number,
        gh_created_at: i.gh_created_at,
        gh_updated_at: i.gh_updated_at,
        gh_closed_at: i.gh_closed_at
      }
    end)
  end

  @doc """
  Returns the amount of issues that are not closed before end_date.

  ## Examples

      iex> Issues.count_open_issues(~N[2024-06-01 00:00:00])
      [%Issues.Issue{}]

  """
  @spec count_open_issues_before(NaiveDateTime.t()) :: non_neg_integer()
  def count_open_issues_before(end_date) do
    EtsIssuesGenServer.list()
    |> Enum.map(fn {_id, i} -> i end)
    |> Enum.filter(fn i -> is_nil(i.gh_closed_at) or NaiveDateTime.after?(i.gh_closed_at, end_date) end)
    |> Enum.count(fn i -> NaiveDateTime.before?(i.gh_created_at, end_date) end)
  end

  @spec count_open_issues() :: non_neg_integer()
  def count_open_issues do
    EtsIssuesGenServer.list() |> Enum.map(fn {_id, i} -> i end) |> Enum.count(fn i -> is_nil(i.gh_closed_at) end)
  end

  @doc """
  Creates an issue.

  ## Examples

      iex> Issues.upsert_issue(%{id: 2328781667, number: 123, gh_created_at: "2024-06-01T12:00:00Z", gh_updated_at: "2024-06-01T13:00:00Z", gh_closed_at: "2024-06-01T14:00:00Z"})
      {:ok, %Issues.Issue{}}

      iex> Issues.upsert_issue(%{field: ""})
      {:error, %Ecto.Changeset{}}

  """
  @spec upsert_issue(map()) :: any()
  def upsert_issue(attrs) do
    gh_created_at = attrs.gh_created_at && attrs.gh_created_at |> DateTime.from_iso8601() |> elem(1)
    gh_updated_at = attrs.gh_updated_at && attrs.gh_updated_at |> DateTime.from_iso8601() |> elem(1)
    gh_closed_at = attrs.gh_closed_at && attrs.gh_closed_at |> DateTime.from_iso8601() |> elem(1)

    issue = %Issue{
      id: attrs.id,
      number: attrs.number,
      gh_created_at: gh_created_at,
      gh_updated_at: gh_updated_at,
      gh_closed_at: gh_closed_at
    }

    write_to_ets([issue])
  end

  @spec upsert_issues(list()) :: non_neg_integer()
  def upsert_issues(items) do
    maps =
      Enum.map(items, fn %{
                           "created_at" => created_at,
                           "updated_at" => updated_at,
                           "closed_at" => closed_at,
                           "id" => id,
                           "number" => number
                         } ->
        gh_created_at = created_at && created_at |> DateTime.from_iso8601() |> elem(1)
        gh_updated_at = updated_at && updated_at |> DateTime.from_iso8601() |> elem(1)
        gh_closed_at = closed_at && closed_at |> DateTime.from_iso8601() |> elem(1)

        %{
          id: id,
          number: number,
          gh_created_at: gh_created_at,
          gh_updated_at: gh_updated_at,
          gh_closed_at: gh_closed_at
        }
      end)

    write_to_ets(maps)
  end

  @spec write_to_ets(list()) :: non_neg_integer()
  defp write_to_ets(items) do
    issues_data =
      for %{
            id: id,
            number: number,
            gh_created_at: gh_created_at,
            gh_updated_at: gh_updated_at,
            gh_closed_at: gh_closed_at
          } <- items do
        issue_data =
          {id,
           %{
             id: id,
             number: number,
             gh_created_at: gh_created_at,
             gh_updated_at: gh_updated_at,
             gh_closed_at: gh_closed_at
           }}

        Kkalb.EtsIssuesGenServer.insert(issue_data)
      end

    Enum.count(issues_data, fn i -> i == true end)
  end
end
