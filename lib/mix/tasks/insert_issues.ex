defmodule Mix.Tasks.InsertIssues do
  @moduledoc "Inserts issues from GitHub-API into the repo with `mix insert_issues`"
  @shortdoc "Inserts issues from API into the repo"

  use Mix.Task

  alias Kkalb.Issues
  require Logger
  # 100 is max for the api
  @elements_to_query 100

  # run this task locally to get all issues into the db
  @impl Mix.Task
  def run(_args) do
    _ = Application.ensure_all_started(:httpoison)
    _ = Application.ensure_all_started(:kkalb)

    run_task(@elements_to_query, Date.new!(2011, 2, 1))
  end

  @spec run_task(any(), Date.t()) :: {binary(), binary()}
  def run_task(elements_to_query, date) do
    response = request_github(elements_to_query, date)

    {_, rate_limit_remaining} =
      Enum.find(response.headers, fn {h, _} -> h == "X-RateLimit-Remaining" end)

    {_, rate_limit_reset} =
      Enum.find(response.headers, fn {h, _} -> h == "X-RateLimit-Reset" end)

    :ok =
      response
      |> Map.get(:body)
      |> Jason.decode!()
      |> insert()

    {rate_limit_remaining, rate_limit_reset}
  end

  defp request_github(elements_to_query, date) do
    date = Date.to_string(date)
    # TODO: separate elements to query from form input elements
    endpoint =
      "https://api.github.com/search/issues?per_page=#{elements_to_query}&q=repo:elixir-lang/elixir+type:issue+created:<#{date}"

    # read from config rather than from system each time
    [api_key: api_key] = Application.fetch_env!(:kkalb, :github)

    headers = [
      {"Authorization", "Bearer #{api_key}"}
    ]

    HTTPoison.get!(endpoint, headers)
  end

  defp insert(%{"items" => items} = _chart_data) do
    # TODO: change to upsert_all
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
    end)
  end

  defp insert(%{"message" => message}), do: Logger.error(message)
end
