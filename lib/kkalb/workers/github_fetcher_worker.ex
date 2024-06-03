defmodule Kkalb.Workers.GithubFetcherWorker do
  use Oban.Worker, queue: :github_fetcher_queue, max_attempts: 10

  alias Mix.Tasks.InsertIssues
  require Logger
  @cooldown 10
  # Kkalb.Workers.GithubFetcherWorker.new(%{"backfill_date" => Date.new!(2024, 6, 1)}) |> Oban.insert()

  @impl true
  def perform(%{args: %{"backfill_date" => backfill_date}}) do
    date = Date.from_iso8601!(backfill_date)

    if Date.compare(date, Date.utc_today()) != :gt do
      %{"backfill_date" => Date.add(date, 7)}
      |> new(schedule_in: @cooldown)
      |> Oban.insert!()
    else
      Logger.info("Stop rescheduling since date reached #{backfill_date}")
    end

    InsertIssues.run_task(100, date)
  end
end
