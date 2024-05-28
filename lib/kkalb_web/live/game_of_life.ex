defmodule KkalbWeb.GameOfLife do
  @moduledoc """
  A simple game of life implementation to show on a webpage.
  """
  use KkalbWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    size = 40

    w = Range.new(0, size - 1)
    w = Enum.to_list(w)
    cells = for row <- w, into: %{}, do: {row, build_row(w)}

    {:ok, socket |> assign(cells: cells) |> assign(size: size) |> assign(timer_refs: [])}
  end

  defp build_row(row) do
    for y <- row, into: %{}, do: {y, :dead}
  end

  @impl Phoenix.LiveView
  def handle_info(:tick, socket) do
    {:noreply, do_iteration(socket)}
  end

  defp do_iteration(socket) do
    cells = socket.assigns.cells
    size = socket.assigns.size
    new_cells = cells |> may_revive(size)
    socket |> assign(cells: new_cells)
  end

  defp may_revive(cells, size) do
    for {row_idx, row_data} <- cells, into: %{} do
      row =
        for {col_idx, cell} <- row_data, into: %{} do
          {col_idx, check_neighbours(cells, cell, row_idx, col_idx, size)}
        end

      {row_idx, row}
    end
  end

  @pot_neighbours [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
  defp check_neighbours(cells, cell, row, col, size) do
    two_d_metrics =
      for {x_off, y_off} <- @pot_neighbours do
        new_row = row - x_off
        new_col = col - y_off

        new_row =
          cond do
            new_row == size -> 0
            new_row == -1 -> size - 1
            true -> new_row
          end

        new_col =
          cond do
            new_col == size -> 0
            new_col == -1 -> size - 1
            true -> new_col
          end

        get_in(cells, [new_row, new_col])
      end

    neighbours = Enum.filter(two_d_metrics, fn m -> m == :alive end) |> length()
    new_val = check_cell(neighbours, cell)

    new_val
  end

  defp check_cell(neighbours, _) when neighbours < 2, do: :dead
  defp check_cell(neighbours, :alive) when neighbours >= 2 and neighbours <= 3, do: :alive
  defp check_cell(neighbours, :alive) when neighbours >= 3, do: :dead
  defp check_cell(3, :dead), do: :alive
  defp check_cell(_, cell), do: cell

  @impl Phoenix.LiveView
  def handle_event("spawn", _, socket) do
    size = socket.assigns.size
    default_range = 0..(size - 1)

    new_cells =
      Enum.reduce(default_range, socket.assigns.cells, fn _, cells ->
        revive(cells, Enum.random(default_range), Enum.random(default_range))
      end)

    {:noreply, socket |> assign(cells: new_cells)}
  end

  def handle_event("start_timer", _, socket) do
    {:ok, ref} = :timer.send_interval(1000, self(), :tick)
    {:noreply, socket |> assign(timer_refs: [ref | socket.assigns.timer_refs])}
  end

  def handle_event("stop_timer", _, socket) do
    timer_refs = socket.assigns.timer_refs
    {ref, refs} = List.pop_at(timer_refs, 0)
    {:ok, :cancel} = :timer.cancel(ref)
    {:noreply, socket |> assign(timer_refs: refs)}
  end

  defp revive(cells, x, y) do
    update_in(cells, [x, y], fn _ -> :alive end)
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h1 class="flex justify-center text-[88px]/[120px] text-cwhite">
      Kevin Kalb
    </h1>
    <div class="flex flex-row w-full border">
      <div class="flex flex-col justify-center gap-4">
        <.input type="range" class="w-1/2" name="slider" value="25" min="0" max="100" step="1" />
        <.button phx-click="spawn" class="flex justify-center items-center w-40">
          Spawn cell
        </.button>
        <.button phx-click="start_timer" class="flex justify-center items-center w-40">
          Start timer
        </.button>
        <.button phx-click="stop_timer" class="flex justify-center items-center w-40">
          Stop timer
        </.button>
      </div>
      <div class="flex w-full items-center">
        <div class="flex justify-center items-center w-full">
          <grid class="grid grid-rows-40 grid-cols-40">
            <%= for {x_idx, row_data} <- @cells, {y_idx, cell} <- row_data do %>
              <div class="row-span-1 col-span-1 border w-4 h-4" id={"cell-#{x_idx}-#{y_idx}"}>
                <%= if cell == :dead do %>
                  <div class="bg-cgray w-full h-full"></div>
                <% else %>
                  <div class="bg-corange w-full h-full"></div>
                <% end %>
              </div>
            <% end %>
          </grid>
        </div>
      </div>
    </div>
    <.footer />
    """
  end
end
