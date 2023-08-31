defmodule KkalbWeb.Live.Index do
  use KkalbWeb, :live_view

  alias KkalbWeb.Live.Chart

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      amount_elements = 10

      result =
        HTTPoison.get!(
          "https://api.github.com/search/issues?per_page=#{amount_elements}&q=repo:elixir-lang/elixir+type:issue+state:open"
        )
        |> Map.get(:body)
        |> Jason.decode!()

      amount_issues = result |> Map.get("total_count")

      items =
        result
        |> Map.get("items")
        |> Enum.map(
          &%{
            "created_at" => &1["created_at"] |> parse_date_time(),
            "closed_at" => &1["closed_at"] |> parse_date_time()
          }
        )

      earliest_date =
        Enum.min_by(items, fn dates_map -> dates_map["created_at"] end, Date)["created_at"]

      latest_date =
        Enum.max_by(items, fn dates_map -> dates_map["created_at"] end, Date)["created_at"]

      range = Date.range(latest_date, earliest_date)
      labels = range |> Enum.to_list()

      values_diff =
        for date_iter <- labels do
          closed_this_date = Enum.count(items, fn item -> item["closed_at"] == date_iter end)
          created_that_date = Enum.count(items, fn item -> item["created_at"] == date_iter end)

          created_that_date + closed_this_date * -1
        end

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

      chart_headings = %{headings: ["# of Elixir issues on Github"]}
      chart_labels = %{labels: Enum.reverse(labels)}
      chart_values = %{values: Enum.reverse(values)}
      chart_title = ""

      {:ok,
       socket
       |> assign(
         chart_headings: chart_headings,
         chart_labels: chart_labels,
         chart_values: chart_values,
         chart_title: chart_title
       )}
    else
      {:ok,
       socket
       |> assign(
         chart_headings: %{headings: ["Pulling data..."]},
         chart_labels: %{labels: [""]},
         chart_values: %{values: []},
         chart_title: "Pulling data..."
       )}
    end
  end

  defp parse_date_time(nil), do: nil

  defp parse_date_time(date_time) do
    date_time |> DateTime.from_iso8601() |> elem(1) |> DateTime.to_date()
  end
end
