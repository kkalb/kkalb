defmodule KkalbWeb.Live.GithubIssueVis.Index do
  @moduledoc """
  Callbacks for handling data for /live path
  """
  require Logger
  use KkalbWeb, :live_view

  alias KkalbWeb.Live.Chart
  alias KkalbWeb.Live.GithubIssueVis.ChartData
  alias KkalbWeb.Live.GithubIssueVis.Transformer

  @impl true
  def mount(_params, _session, socket) do
    elements_to_query = 20

    default_chart_data = %ChartData{}

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
      "https://api.github.com/search/issues?per_page=#{elements_to_query}&q=repo:elixir-lang/elixir+type:issue"
    )
  end

  @impl true
  def handle_event("change_elements_to_query", %{"count" => elements}, socket) do
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

  defp transform(%{"message" => message}) do
    Logger.info(message)
    %{message: "API limit exceeded. Please wait for some seconds"}
  end

  defp transform(query_result) do
    query_result
    |> Map.get("items")
    |> Enum.each(fn item ->
      %{
        "closed_at" => closed_at,
        "created_at" => created_at
      } = item

      IO.inspect(created_at, label: "created_at")
      IO.inspect(closed_at, label: "closed_at")
    end)

    Transformer.transform(query_result)
  end

  @spec assign_chart_data(map(), %Phoenix.Socket{}) :: %Phoenix.Socket{}
  defp assign_chart_data(%{message: message}, socket) do
    put_flash(socket, :error, message)
  end

  @spec assign_chart_data(%ChartData{}, %Phoenix.Socket{}) :: %Phoenix.Socket{}
  defp assign_chart_data(%ChartData{} = chart_data, socket) do
    IO.inspect(chart_data)

    socket
    |> assign(
      chart_headings: chart_data.chart_headings,
      chart_labels: chart_data.chart_labels,
      chart_values: chart_data.chart_values,
      chart_title: chart_data.chart_title
    )
  end
end
