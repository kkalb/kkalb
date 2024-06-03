defmodule Mix.Tasks.InsertIssues do
  @moduledoc "Inserts issues from GitHub-API into the repo with `mix insert_issues`"
  @shortdoc "Inserts issues from API into the repo"

  use Mix.Task
  # alias KkalbWeb.Live.GithubIssueVis.Transformer
  # alias KkalbWeb.Live.GithubIssueVis.ChartData
  alias Kkalb.Issues

  # 100 is max for the api
  @elements_to_query 100

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:httpoison)
    Application.ensure_all_started(:kkalb)

    @elements_to_query
    |> request_github()
    |> Map.get(:body)
    |> Jason.decode!()
    |> insert()
  end

  defp request_github(elements_to_query) do
    HTTPoison.get!(
      "https://api.github.com/search/issues?per_page=#{elements_to_query}&q=repo:elixir-lang/elixir+type:issue+closed:<2011-01-01"
    )
  end

  defp insert(%{"items" => items} = _chart_data) do
    Enum.each(items, fn %{
                          "closed_at" => closed_at,
                          "created_at" => created_at,
                          "id" => id,
                          "number" => number,
                          "updated_at" => updated_at
                        } ->
      {:ok, _issue} =
        Issues.upsert_issue(%{
          id: id,
          number: number,
          gh_created_at: created_at,
          gh_updated_at: updated_at,
          gh_closed_at: closed_at
        })

      # IO.inspect(issue)
    end)
  end
end
