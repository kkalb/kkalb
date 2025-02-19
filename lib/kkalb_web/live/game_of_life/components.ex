defmodule KkalbWeb.Live.GameOfLife.Components do
  @moduledoc """
  Some helper functions to reduce main html and have logical units.
  """

  use KkalbWeb, :live_view

  def buttons(assigns) do
    ~H"""
    <div class="flex flex-row justify-center md:gap-4 gap-2 w-1/2 h-full">
      <.button phx-click="spawn_random">
        Spawn cells
      </.button>
      <.button phx-click="spawn_glider">
        Spawn glider
      </.button>
      <.button phx-click="start_timer" disabled={not is_nil(@timer_ref)}>
        <.icon name="hero-play" class="w-6 h-6" />
      </.button>
      <.button phx-click="stop_timer" disabled={is_nil(@timer_ref)}>
        <.icon name="hero-pause" class="w-6 h-6" />
      </.button>
    </div>
    """
  end

  def slider(assigns) do
    ~H"""
    <.simple_form for={%{}} phx-change="change_speed" class="flex w-4 h-72">
      <.input
        type="range"
        phx-debounce="250"
        dir="vertical"
        label="Speed"
        name="speed"
        value={@timer_speed}
        min="100"
        max="1000"
        step="10"
      />
    </.simple_form>
    """
  end

  # building the grid ourselfes with only divs scales better than 'display: grid'
  def grid(assigns) do
    cells = cells_to_grid(assigns.cells)
    assigns = assign(assigns, cells: cells)

    ~H"""
    <div class="mt-2" id="big_canvas_div">
      <canvas
        class="sm:w-[500px] sm:h-[500px] w-[250px] h-[250px] bg-cgray border-white border"
        id="big_canvas"
        width="250"
        height="250"
        gridColor="#EF8354"
        phx-hook="Canvas"
      >
      </canvas>
    </div>
    """
  end

  defp cells_to_grid(cells) do
    cells
    |> Enum.map(fn {x, row} ->
      {x, Enum.sort_by(row, fn {y, _cell} -> y end, :asc)}
    end)
    |> Enum.sort_by(fn {x, _row} -> x end, :asc)
  end
end
