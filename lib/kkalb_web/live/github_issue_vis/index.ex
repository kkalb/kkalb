defmodule KkalbWeb.Live.GithubIssueVis.Index do
  @moduledoc """
  Callbacks github graph visualization
  """
  require Logger
  use KkalbWeb, :live_view

  alias KkalbWeb.Live.Chart
  alias KkalbWeb.Live.GithubIssueVis.ChartData
  alias KkalbWeb.Live.GithubIssueVis.Transformer
  alias Kkalb.Issues

  @impl true
  def mount(_params, _session, socket) do
    elements_to_query = 20
    start_date = NaiveDateTime.new!(Date.new!(2024, 5, 1), Time.new!(0, 0, 0))

    {chart_data, loading} =
      if connected?(socket) do
        issues = Issues.list_issues(start_date)
        # takes 3 s with all issues, will be refactored soon
        chart_data = Transformer.convert(issues, start_date)

        {chart_data, false}
      else
        {%ChartData{}, true}
      end

    IO.inspect(chart_data)

    {:ok,
     socket
     |> assign(chart_data: chart_data)
     |> assign(start_date: start_date)
     |> assign(loading: loading)
     |> assign(elements_to_query: elements_to_query)}
  end

  @impl true
  def handle_event("change_elements_to_query", %{"count" => _elements}, socket) do
    issues = Issues.list_issues(socket.assigns.start_date)
    chart_data = Transformer.convert(issues, socket.assigns.start_date)

    {:noreply,
     socket
     #  |> assign(elements_to_query: elements)
     |> assign(chart_data: chart_data)}
  end
end
