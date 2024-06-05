defmodule KkalbWeb.Live.GithubIssueVis.Transformer do
  alias KkalbWeb.Live.GithubIssueVis.ChartData
  alias Kkalb.Issues

  @spec convert([%Issues.Issue{}], NaiveDateTime.t()) :: %ChartData{} | any()
  def convert(issues, nv_start_date) do
    # we need to know what the current amount of unclosed issues is
    # since we no longer query all issues for every single visualisation
    count_open_issues_before = Issues.count_open_issues_before(nv_start_date)
    start_date = NaiveDateTime.to_date(nv_start_date)

    # Enum.each(Enum.sort_by(Issues.list_issues(), fn i -> i.gh_created_at end, Date), fn issue ->
    #   created = issue.gh_created_at
    #   closed = issue.gh_closed_at
    #   IO.inspect("#{created} -> #{closed}")
    # end)

    issues_map = build_map(issues, start_date)

    {labels, values} =
      issues_map
      |> Enum.map(fn tuple -> tuple end)
      |> Enum.sort_by(fn {date, _} -> date end, Date)
      |> Enum.unzip()

    # [~D[2024-05-01], ~D[2024-05-08], ~D[2024-05-15], ~D[2024-05-22],  ~D[2024-05-29]]
    # [1, 0, 0, 0, 0]
    # values is a list of changes, so issues per day is
    # [1, 1, 1, 1, 1] caluclated. Now we need to apply the issues that were already opened before
    # which is two in the test case. One for the one opened at the 2024-05-29 and one was opened at 2024-04-01.
    values = transform_values(values, count_open_issues_before, [])

    %ChartData{
      chart_headings: %{headings: ["# of Elixir issues on Github"]},
      chart_labels: %{labels: labels},
      chart_values: %{values: values},
      chart_title: %{title: "Number of Elixir issues on Github over time"}
    }
  end

  defp build_map(issues, start_date) do
    # still decreasing order, from 'now' to the 'past'
    Enum.reduce(issues, %{}, fn issue, acc ->
      created_at = DateTime.to_date(issue.gh_created_at)
      closed? = not is_nil(issue.gh_closed_at)
      created_before? = Date.before?(created_at, start_date)

      case {closed?, created_before?} do
        {false, true} ->
          acc

        {false, false} ->
          acc |> Map.update(created_at, 1, &(&1 + 1))

        {true, true} ->
          closed_at = DateTime.to_date(issue.gh_closed_at)
          acc |> Map.update(closed_at, -1, &(&1 - 1))

        {true, false} ->
          closed_at = DateTime.to_date(issue.gh_closed_at)
          acc |> Map.update(created_at, 1, &(&1 + 1)) |> Map.update(closed_at, -1, &(&1 - 1))
      end
    end)
  end

  defp transform_values([], _count_issues_before, res), do: Enum.reverse(res)

  defp transform_values([value | values], count_issues, res) do
    transform_values(values, count_issues + value, [count_issues + value | res])
  end
end
