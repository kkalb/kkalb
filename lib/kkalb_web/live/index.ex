defmodule KkalbWeb.Live.Index do
  @moduledoc """
  Callbacks for handling data for /live path
  """
  use KkalbWeb, :live_view

  alias KkalbWeb.Live.Chart

  @impl true
  def mount(_params, _session, socket) do
    elements_to_query = 10

    default_chart_data = %{
      chart_headings: %{headings: ["Pulling data..."]},
      chart_labels: %{labels: [""]},
      chart_values: %{values: []},
      chart_title: "Pulling data..."
    }

    if connected?(socket) do
      send(self(), {:fetch_from_api, elements_to_query})
    end

    {:ok,
     default_chart_data
     |> assign_chart_data(socket)
     |> assign(elements_to_query: elements_to_query)}
  end

  @impl true
  def handle_info({:fetch_from_api, elements}, socket) do
    view = self()

    Task.start(fn ->
      chart_data =
        elements
        |> request_github()
        |> Map.get(:body)
        |> Jason.decode!()
        |> transform()

      send(view, {:fetch_from_api_complete, chart_data})
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:fetch_from_api_complete, chart_data}, socket) do
    {:noreply, chart_data |> assign_chart_data(socket) |> assign(loading: false)}
  end

  defp request_github(elements_to_query) do
    HTTPoison.get!(
      "https://api.github.com/search/issues?per_page=#{elements_to_query}&q=repo:elixir-lang/elixir+type:issue+state:open"
    )
  end

  @impl true
  def handle_event("change_elements_to_query", %{"change_elements_to_query" => elements}, socket) do
    {:noreply, socket |> assign(elements_to_query: elements) |> build_chart(elements)}
  end

  defp build_chart(socket, elements_to_query) do
    elements_to_query
    |> request_github()
    |> Map.get(:body)
    |> Jason.decode!()
    |> transform()
    |> assign_chart_data(socket)
  end

  defp transform(query_result) do
    amount_issues = query_result |> Map.get("total_count")

    items =
      query_result
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

    %{
      chart_headings: %{headings: ["# of Elixir issues on Github"]},
      chart_labels: %{labels: Enum.reverse(labels)},
      chart_values: %{values: Enum.reverse(values)},
      chart_title: ""
    }
  end

  defp assign_chart_data(chart_data, socket) do
    socket
    |> assign(
      chart_headings: chart_data.chart_headings,
      chart_labels: chart_data.chart_labels,
      chart_values: chart_data.chart_values,
      chart_title: chart_data.chart_title
    )
  end

  defp parse_date_time(nil), do: nil

  defp parse_date_time(date_time) do
    date_time |> DateTime.from_iso8601() |> elem(1) |> DateTime.to_date()
  end
end
