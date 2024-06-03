defmodule KkalbWeb.Live.GithubIssueVis.Transformer do
  alias KkalbWeb.Live.GithubIssueVis.ChartData
  alias Kkalb.Issues.Issue

  @spec transform([%Issue{}]) :: %ChartData{}
  def transform(issues, elements_to_show \\ 20) do
    amount_issues = Enum.count(issues, fn item -> is_nil(item.gh_closed_at) end)
    earliest_date = Enum.min_by(issues, fn item -> item.gh_created_at end, DateTime).gh_created_at
    latest_date = Enum.max_by(issues, fn item -> item.gh_created_at end, DateTime).gh_created_at

    range = Date.range(earliest_date, latest_date)

    issues =
      issues
      |> Enum.map(fn item ->
        %{
          gh_created_at: item.gh_created_at |> parse_date_time(),
          gh_closed_at: item.gh_closed_at |> parse_date_time()
        }
      end)

    values_diff =
      for date_iter <- range |> Enum.to_list() |> Enum.reverse() do
        closed_this_date =
          Enum.count(issues, fn item ->
            item.gh_closed_at == date_iter
          end)

        created_that_date =
          Enum.count(issues, fn item -> item.gh_created_at == date_iter end)

        created_that_date + closed_this_date * -1
      end

    # IO.inspect(values_diff)
    # example value for values_diff: [0, 0, -1, 0, 1, 1, 0, -2, 2, 1, 1] (desc)
    {_, values} =
      Enum.reduce(values_diff, {0, [amount_issues]}, fn x, acc ->
        {new_diff, new_ele} =
          case acc do
            {0, [amount_issues]} ->
              {x, [amount_issues, amount_issues + x]}

            {diff, l} ->
              last_ele = List.last(l)
              {diff + x, List.insert_at(l, -1, last_ele + x)}
          end

        {new_diff, new_ele}
      end)

    # Enum.each(Enum.zip(Enum.to_list(range), Enum.reverse(values)), fn {a, b} ->
    #   IO.inspect(b, label: a)
    # end)

    range = Enum.to_list(range)
    values = Enum.reverse(values)

    # TODO: refactor complete data building
    {range, values} =
      Enum.zip(range, values)
      |> Enum.reverse()
      |> Enum.take(elements_to_show)
      |> Enum.reverse()
      |> Enum.unzip()

    %ChartData{
      chart_headings: %{headings: ["# of Elixir issues on Github"]},
      chart_labels: %{labels: range},
      chart_values: %{values: values},
      chart_title: %{title: "Number of Elixir issues on Github over time"}
    }
  end

  defp parse_date_time(date_time), do: date_time && DateTime.to_date(date_time)
end
