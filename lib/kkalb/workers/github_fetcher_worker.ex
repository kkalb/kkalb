defmodule Kkalb.Workers.GithubFetcherWorker do
  @moduledoc """
  Trigger with
  ```
  Kkalb.Workers.GithubFetcherWorker.new(%{"backfill_date" => Date.utc_today()}) |> Oban.insert()
  Kkalb.Workers.GithubFetcherWorker.new(%{}) |> Oban.insert()
  ```
  """
  use Oban.Worker, queue: :github_fetcher_queue, max_attempts: 10

  alias Mix.Tasks.InsertIssues

  require Logger

  @first_issue_date Date.new!(2011, 2, 1)

  @impl Oban.Worker
  @spec perform(any()) :: :ok
  def perform(%{args: %{"backfill_date" => backfill_date}}) do
    date = Date.from_iso8601!(backfill_date)

    {rate_limit_remaining, rate_limit_reset} = InsertIssues.run_task(100, date)

    rate_limit_remaining = String.to_integer(rate_limit_remaining)

    wait_time = speed_throttle(rate_limit_reset, rate_limit_remaining)

    _ =
      cond do
        Date.before?(date, @first_issue_date) ->
          Logger.info("Stop rescheduling since date reached #{backfill_date}")

        # when we reached the rate limit, we reschedule the same date
        rate_limit_remaining <= 1 ->
          %{"backfill_date" => date}
          |> new(schedule_in: wait_time)
          |> Oban.insert!()

        # as long as the backfill date is later than the stop date, we continue rescheduling
        true ->
          %{"backfill_date" => Date.add(date, -10)}
          |> new(schedule_in: wait_time)
          |> Oban.insert!()
      end

    :ok
  end

  def perform(_) do
    _job =
      %{"backfill_date" => Date.utc_today()}
      |> new(schedule_in: 0)
      |> Oban.insert!()

    :ok
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

    Logger.info("Remaining rate #{rate_limit_remaining} for #{seconds_remaining} s")
    # we try to never reach the limit, since there can be a secondary
    # limit which we ensure not to reach with this
    # we want 0.5 seconds but we can only do full second waits with Oban
    if rate_limit_remaining >= 1, do: Enum.random([0, 1]), else: seconds_remaining + 1
  end
end
