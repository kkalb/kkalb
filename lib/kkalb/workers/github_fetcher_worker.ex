defmodule Kkalb.Workers.GithubFetcherWorker do
  @moduledoc """
  Trigger with
  iex -S mix ps
  and one of the follwing in the console to start the job scheduler
  ```
  Kkalb.Workers.GithubFetcherWorker.new(%{"backfill_date" => Date.utc_today()}) |> Oban.insert()
  Kkalb.Workers.GithubFetcherWorker.new(%{}) |> Oban.insert()
  ```
  """

  # use Oban.Worker, queue: :github_fetcher_queue, max_attempts: 10

  alias Mix.Tasks.InsertIssues

  require Logger

  @first_issue_date Date.new!(2011, 2, 1)

  @spec perform(map()) :: :ok
  def perform(%{"backfill_date" => backfill_date}) do
    IO.inspect(backfill_date, label: "perform matched")
    date = backfill_date

    {rate_limit_remaining, rate_limit_reset, issues_created} = InsertIssues.run_task(100, date)

    rate_limit_remaining = String.to_integer(rate_limit_remaining)

    wait_time = speed_throttle(rate_limit_reset, rate_limit_remaining) * 1000

    _ =
      cond do
        Date.before?(date, @first_issue_date) ->
          Logger.info("Stop rescheduling since date reached #{backfill_date}")

        # when we reached the rate limit, we reschedule the same date but wait longer
        rate_limit_remaining <= 1 ->
          IO.inspect(rate_limit_remaining, label: "rate_limit_remaining")
          IO.inspect(rate_limit_reset, label: "rate_limit_reset")
          IO.inspect(wait_time, label: "wait_time")
          Process.sleep(wait_time)
          perform(%{"backfill_date" => Date.add(date, -14)})

        # as long as the backfill date is later than the stop date, we continue rescheduling
        true ->
          backfill_date = if issues_created >= 100, do: Date.add(date, 30), else: Date.add(date, -60)
          IO.inspect(issues_created)
          Process.sleep(wait_time)
          perform(%{"backfill_date" => backfill_date})
      end

    :ok
  end

  @doc """
  When backfill_date not provided, we take the first issue date.
  """
  def perform(args) do
    IO.inspect(args, label: "perform unmatched")

    perform(%{"backfill_date" => Date.utc_today(), "schedule_in" => 0})
  end

  # decelerate when limit gets slower
  # and rate_limit_remaining is between 0 and 30.
  @spec speed_throttle(binary(), non_neg_integer()) :: non_neg_integer()
  defp speed_throttle(rate_limit_reset, rate_limit_remaining) do
    seconds_remaining =
      rate_limit_reset
      |> String.to_integer()
      |> DateTime.from_unix!()
      |> DateTime.diff(DateTime.utc_now(), :second)

    IO.inspect(seconds_remaining, label: "seconds_remaining")
    Logger.info("Remaining rate #{rate_limit_remaining} for #{seconds_remaining} s")
    # we try to never reach the limit, since there can be a secondary
    # limit which we ensure not to reach with this
    # we want 0.5 seconds but we can only do full second waits with Oban
    if rate_limit_remaining >= 1, do: Enum.random([0, 1]), else: seconds_remaining + 1
  end
end
