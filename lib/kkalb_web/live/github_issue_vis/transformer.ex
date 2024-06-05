defmodule KkalbWeb.Live.GithubIssueVis.Transformer do
  alias KkalbWeb.Live.GithubIssueVis.ChartData
  alias Kkalb.Issues

  # %Kkalb.Issues.Issue{
  #   id: Decimal.new("5"),
  #   number: 1005,
  #   gh_created_at: ~U[2024-05-29 12:00:00Z],
  #   gh_updated_at: ~U[2024-05-29 13:00:00Z],
  #   gh_closed_at: nil,
  #   inserted_at: ~N[2024-06-04 13:00:55],
  #   updated_at: ~N[2024-06-04 13:00:55]
  # }

  @spec convert([%Issues.Issue{}], NaiveDateTime.t()) :: %ChartData{} | any()
  def convert(issues, nv_start_date) do
    # we need to know what the current amount of unclosed issues is
    # since we no longer query all issues for every single visualisation
    count_open_issues_before = Issues.count_open_issues_before(nv_start_date)

    start_date = NaiveDateTime.to_date(nv_start_date)
    IO.inspect(count_open_issues_before, label: "count")

    Enum.each(Enum.sort_by(Issues.list_issues(), fn i -> i.gh_created_at end, Date), fn issue ->
      created = issue.gh_created_at
      closed = issue.gh_closed_at
      IO.inspect("#{created} -> #{closed}")
    end)

    # still decreasing order, from 'now' to the 'past'
    issues_map =
      Enum.reduce(issues, %{}, fn issue, acc ->
        created_at = DateTime.to_date(issue.gh_created_at)

        if is_nil(issue.gh_closed_at) do
          if Date.before?(created_at, start_date) do
            acc
          else
            acc |> Map.update(created_at, 1, &(&1 + 1))
          end
        else
          closed_at = DateTime.to_date(issue.gh_closed_at)

          if Date.before?(created_at, start_date) do
            acc |> Map.update(closed_at, -1, &(&1 - 1))
          else
            acc |> Map.update(created_at, 1, &(&1 + 1)) |> Map.update(closed_at, -1, &(&1 - 1))
          end
        end
      end)

    IO.inspect(issues_map)

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
    IO.inspect(values)
    values = transform_values(values, count_open_issues_before, [])
    IO.inspect(values)

    %ChartData{
      chart_headings: %{headings: ["# of Elixir issues on Github"]},
      chart_labels: %{labels: labels},
      chart_values: %{values: values},
      chart_title: %{title: "Number of Elixir issues on Github over time"}
    }
  end

  defp transform_values([], _count_issues_before, res), do: res

  defp transform_values([value | values], count_issues, res) do
    transform_values(values, count_issues + value, [count_issues + value | res])
  end
end
