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

    {chart_data, loading} =
      if connected?(socket) do
        issues = Issues.list_issues()
        # takes 3 s with all issues, will be refactored soon
        chart_data = Transformer.transform(issues)

        {chart_data, false}
      else
        {%ChartData{}, true}
      end

    {:ok,
     socket
     |> assign(chart_data: chart_data)
     |> assign(loading: loading)
     |> assign(elements_to_query: elements_to_query)}
  end

  @impl true
  def handle_event("change_elements_to_query", %{"count" => elements}, socket) do
    issues = Issues.list_issues()
    chart_data = Transformer.transform(issues, String.to_integer(elements))

    {:noreply,
     socket
     |> assign(elements_to_query: elements)
     |> assign(chart_data: chart_data)}
  end
end
