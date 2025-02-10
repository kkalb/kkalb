defmodule KkalbWeb.Live.GithubIssueVis.Index do
  @moduledoc """
  Callbacks github graph visualization
  """
  use KkalbWeb, :live_view

  alias Kkalb.GithubIssueVis.ChartData
  alias KkalbWeb.Live.Chart
  alias KkalbWeb.Live.GithubIssueVis.Transformer

  require Logger

  @db_module Kkalb.Issues
  @ets_module Kkalb.IssuesEts

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    start_date = NaiveDateTime.new!(Date.new!(2024, 1, 1), Time.new!(0, 0, 0))
    # Used module is set in config file. In prod, we use ets to save money on the DB. On dev, DB is used.
    issue_storage = Application.get_env(:kkalb, :issue_storage)
    use_db? = issue_storage == @db_module

    {chart_data, loading} =
      if connected?(socket) do
        chart_data =
          start_date
          |> get_storage_module(use_db?).list_issues()
          |> Transformer.convert(start_date, issue_storage)

        {chart_data, false}
      else
        {%ChartData{}, true}
      end

    {:ok,
     socket
     |> assign(chart_data: chart_data)
     |> assign(start_date: start_date)
     |> assign(loading: loading)
     |> assign(use_db?: use_db?)
     |> assign(issue_storage: issue_storage)}
  end

  defp get_storage_module(true), do: @db_module
  defp get_storage_module(false), do: @ets_module

  @impl Phoenix.LiveView
  def handle_event("date_selected", %{"date" => selected_date}, socket) do
    start_date = selected_date |> Date.from_iso8601!() |> NaiveDateTime.new!(Time.new!(0, 0, 0))
    issue_storage = socket.assigns.issue_storage

    issues = get_storage_module(socket.assigns.use_db?).list_issues(start_date)
    chart_data = Transformer.convert(issues, start_date, issue_storage)

    {:noreply, socket |> assign(chart_data: chart_data) |> assign(start_date: start_date)}
  end

  @impl Phoenix.LiveView
  def handle_event("switch_state", %{"id" => "toggle_db"}, socket) do
    use_db? = !socket.assigns.use_db?

    issue_storage = if use_db?, do: @db_module, else: @ets_module

    start_date = socket.assigns.start_date
    issues = get_storage_module(use_db?).list_issues(start_date)
    chart_data = Transformer.convert(issues, start_date, issue_storage)

    {:noreply, assign(socket, chart_data: chart_data, use_db?: use_db?, issue_storage: issue_storage)}
  end

  defp switch(%{type: "switch"} = assigns) do
    value = assigns.value
    color = if value, do: "bg-corange", else: "bg-cgray"
    pos = if value, do: "translate-x-[40px]", else: "translate-x-0"
    pos_text = if value, do: "-translate-x-[18px]", else: "translate-x-2"
    assigns = assign(assigns, color: color, pos: pos, pos_text: pos_text)

    ~H"""
    <div phx-feedback-for={@name} class="flex flex-col h-full w-full items-center justify-center mb-4">
      <.label for={@id}>{@label}</.label>

      <span
        phx-click="switch_state"
        phx-value-id={@id}
        id={"switch-state-#{@id}"}
        class={[
          "realtive inline-block flex-shrink-0 h-6 w-[60px] border-2 border-transparent rounded-full cursor-pointer mt-4",
          @color
        ]}
      >
        <span
          aria-hidden="true"
          class={[
            "inline-block h-4 w-4 rounded-full bg-white shadow transform transition ease-in-out duration-200",
            @pos
          ]}
        >
        </span>
        <span class={[
          "inline-block h-4 w-4 rounded-full shadow transform transition ease-in-out duration-200 -translate-y-[2px] text-cwhite",
          @pos_text
        ]}>
          {if @value, do: "DB", else: "ETS"}
        </span>
      </span>
    </div>
    """
  end
end
