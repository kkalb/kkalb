defmodule KkalbWeb.GameOfLife do
  @moduledoc """

  """
  use KkalbWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    rows = 0..9 |> Enum.to_list()

    {:ok, socket |> assign(rows: rows)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex m-20 bg-white">
      <.table id="gol" rows={@rows}>
        <:col :let={row} label="col1"><%= row %></:col>
        <:col :let={row} label="col2"><%= row %></:col>
      </.table>
    </div>
    """
  end
end
