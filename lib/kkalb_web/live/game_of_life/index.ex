defmodule KkalbWeb.Live.GameOfLife.Index do
  @moduledoc """
  A simple game of life implementation to show on a webpage.
  """
  use KkalbWeb, :live_view

  import KkalbWeb.Live.GameOfLife.Components

  alias KkalbWeb.Live.GameOfLife.GameLogic

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    size = 25

    {:ok,
     socket
     |> assign(cells: GameLogic.build_empty_cells(size))
     |> assign(size: size)
     |> assign(timer_ref: nil)
     |> assign(timer_speed: "500")}
  end

  @impl Phoenix.LiveView
  def handle_info(:tick, %{assigns: %{cells: cells, size: size}} = socket) do
    new_cells = GameLogic.do_game_cycle(cells, size)
    {:noreply, update_canvas_and_socket(socket, new_cells)}
  end

  @impl Phoenix.LiveView
  def handle_event("spawn_glider", _, socket) do
    glider_cells =
      socket.assigns.cells
      |> GameLogic.revive(3, 3)
      |> GameLogic.revive(4, 4)
      |> GameLogic.revive(5, 4)
      |> GameLogic.revive(5, 3)
      |> GameLogic.revive(5, 2)

    {:noreply, update_canvas_and_socket(socket, glider_cells)}
  end

  @impl Phoenix.LiveView
  def handle_event("spawn_random", _, socket) do
    size = socket.assigns.size
    default_range = 0..(size - 1)

    new_cells =
      Enum.reduce(default_range, socket.assigns.cells, fn _, cells ->
        GameLogic.revive(cells, Enum.random(default_range), Enum.random(default_range))
      end)

    {:noreply, update_canvas_and_socket(socket, new_cells)}
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

  defp update_canvas_and_socket(socket, new_cells) do
    socket
    |> push_event("spawn", new_cells)
    |> assign(cells: new_cells)
  end

  # `min` is 100 ms and `max` is 1000 ms.
  # Since a lower interval is faster and we want to show a "Speed" label,
  # we have to map 100 to 1000 and vice versa.
  defp start_timer(speed) do
    mapped_speed = speed |> String.to_integer() |> Kernel.-(1100) |> abs()
    {:ok, ref} = :timer.send_interval(mapped_speed, self(), :tick)
    ref
  end

  # when timer already stopped
  defp stop_timer(nil), do: nil

  defp stop_timer(timer_ref) do
    {:ok, :cancel} = :timer.cancel(timer_ref)
    nil
  end
end
