defmodule KkalbWeb.Live.GithubIssueVis.Index do
  @moduledoc """
  Callbacks for handling data for /live path
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

    if connected?(socket) do
      send(self(), {:fetch_from_db, elements_to_query})
    end

    {:ok,
     socket
     |> assign(chart_data: %ChartData{})
     |> assign(elements_to_query: elements_to_query)}
  end

  @impl true
  def handle_info({:fetch_from_db, _elements}, socket) do
    view = self()

    Task.start(fn ->
      issues = Issues.list_issues()
      send(view, {:fetch_from_db_complete, issues})
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:fetch_from_db_complete, issues}, socket) do
    chart_data = Transformer.transform(issues)

    {:noreply,
     socket
     |> assign(chart_data: chart_data)
     |> assign(loading: false)}
  end

  @impl true
  def handle_event("change_elements_to_query", %{"count" => elements}, socket) do
    issues = Issues.list_issues()
    chart_data = Transformer.transform(issues, String.to_integer(elements))
    IO.inspect(elements)

    {:noreply,
     socket
     |> assign(elements_to_query: elements)
     |> assign(chart_data: chart_data)}
  end
end
