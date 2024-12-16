defmodule KkalbWeb.Live.GameOfLife.Index do
  @moduledoc """
  A simple game of life implementation to show on a webpage.
  """
  use KkalbWeb, :live_view

  @dead 0
  @alive 1

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    # size is 720 / 10
    size = 25

    {:ok,
     socket
     |> assign(cells: build_empty_cells(size))
     |> assign(size: size)
     |> assign(timer_ref: nil)
     |> assign(timer_speed: "500")}
  end

  @impl Phoenix.LiveView
  def handle_info(:tick, socket) do
    {:noreply, do_game_cycle(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("spawn_glider", _, socket) do
    glider_cells =
      socket.assigns.cells
      |> revive(3, 3)
      |> revive(4, 4)
      |> revive(5, 4)
      |> revive(5, 3)
      |> revive(5, 2)

    socket = push_event(socket, "spawn", glider_cells)

    {:noreply, assign(socket, cells: glider_cells)}
  end

  @impl Phoenix.LiveView
  def handle_event("spawn_random", _, socket) do
    size = socket.assigns.size
    default_range = 0..(size - 1)

    new_cells =
      Enum.reduce(default_range, socket.assigns.cells, fn _, cells ->
        revive(cells, Enum.random(default_range), Enum.random(default_range))
      end)

    socket = push_event(socket, "spawn", new_cells)

    {:noreply, assign(socket, cells: new_cells)}
  end

  def handle_event("start_timer", _, socket) do
    {:noreply, assign(socket, timer_ref: start_timer(socket.assigns.timer_speed))}
  end

  def handle_event("stop_timer", _, socket) do
    {:noreply, assign(socket, timer_ref: stop_timer(socket.assigns.timer_ref))}
  end

  @doc """
  When timer is not running, we only change the speed.
  When timer is running, we stop it, change speed, and start again.
  """
  def handle_event("change_speed", %{"speed" => timer_speed}, %{assigns: %{timer_ref: nil}} = socket) do
    {:noreply, assign(socket, timer_speed: timer_speed)}
  end

  def handle_event("change_speed", %{"speed" => timer_speed}, %{assigns: %{timer_ref: timer_ref}} = socket) do
    nil = stop_timer(timer_ref)
    timer_ref = start_timer(timer_speed)
    {:noreply, assign(socket, timer_ref: timer_ref, timer_speed: timer_speed)}
  end

  # `min` is 100 ms and `max` is 1000 ms.
  # Since a lower interval is faster and we want to show a "Speed" label,
  # we have to map 100 to 1000 and vice versa.
  defp start_timer(speed) do
    mapped_speed = speed |> String.to_integer() |> Kernel.-(1100) |> abs()
    {:ok, ref} = :timer.send_interval(mapped_speed, self(), :tick)
    ref
  end

  defp stop_timer(nil) do
    IO.puts("Timer already stopped")
    nil
  end

  defp stop_timer(timer_ref) do
    {:ok, :cancel} = :timer.cancel(timer_ref)
    nil
  end

  defp build_empty_cells(size) do
    one_dim = Range.new(0, size - 1)
    one_dim = Enum.to_list(one_dim)
    for row <- one_dim, into: %{}, do: {row, build_row(one_dim)}
  end

  defp build_row(row) do
    for y <- row, into: %{}, do: {y, @dead}
  end

  defp do_game_cycle(%{assigns: %{cells: cells, size: size}} = socket) do
    new_cells = may_revive(cells, size)

    socket = push_event(socket, "spawn", new_cells)

    assign(socket, cells: new_cells)
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

  defp revive(cells, x, y) do
    update_in(cells, [x, y], fn _ -> @alive end)
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

    neighbours = two_d_metrics |> Enum.filter(fn m -> m == @alive end) |> length()
    new_val = check_cell(neighbours, cell)

    new_val
  end

  defp check_cell(neighbours, _) when neighbours < 2, do: @dead
  defp check_cell(neighbours, @alive) when neighbours >= 2 and neighbours <= 3, do: @alive
  defp check_cell(neighbours, @alive) when neighbours >= 3, do: @dead
  defp check_cell(3, @dead), do: @alive
  defp check_cell(_, cell), do: cell

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-full">
      <.header text="Game of Life">
        Conway's Game of Life is one of the most fascinating things to watch on an computer.
      </.header>

      <div class="flex flex-col justify-center items-center gap-y-2">
        <.buttons timer_ref={@timer_ref} />

        <div class="flex w-full items-center h-full">
          <div class="flex justify-center w-full h-full">
            <.grid cells={@cells} />

            <.slider timer_speed={@timer_speed} />
          </div>
        </div>
      </div>
      <.footer />
    </div>
    """
  end

  defp buttons(assigns) do
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

  defp cells_to_grid(cells) do
    cells
    |> Enum.map(fn {x, row} ->
      {x, Enum.sort_by(row, fn {y, _cell} -> y end, :asc)}
    end)
    |> Enum.sort_by(fn {x, _row} -> x end, :asc)
  end

  # building the grid ourselfes with only divs scales better than 'display: grid'
  defp grid(assigns) do
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

  # using 'display: grid' limits us on how to calculate how many grid cells we want to use
  # defp real_grid(assigns) do
  #   assigns = assign(assigns, cells: cells_to_grid(assigns.cells))

  #   ~H"""
  #   <grid class="grid grid-rows-40 grid-cols-40 h-full">
  #     <%= for {x_idx, row_data} <- @cells, {y_idx, cell} <- row_data do %>
  #       <div class="row-span-1 col-span-1 border w-4 h-4" id={"cell-#{x_idx}-#{y_idx}"}>
  #         <.cell cell={cell} />
  #       </div>
  #     <% end %>
  #   </grid>
  #   """
  # end

  # defp cell(%{cell: @dead} = assigns) do
  #   ~H"""
  #   <div class="bg-cgray w-full h-full"></div>
  #   """
  # end

  # defp cell(%{cell: @alive} = assigns) do
  #   ~H"""
  #   <div class="bg-corange w-full h-full"></div>
  #   """
  # end

  defp slider(assigns) do
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
end
