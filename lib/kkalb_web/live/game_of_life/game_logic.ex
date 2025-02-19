defmodule KkalbWeb.Live.GameOfLife.GameLogic do
  @moduledoc """
  All functions used to handle data for the UI belong here.
  """
  import KkalbWeb.Live.GameOfLife.CheckCell

  @dead 0
  @alive 1
  define_check_cell()

  def build_empty_cells(size) do
    one_dim = Range.new(0, size - 1)
    one_dim = Enum.to_list(one_dim)
    for row <- one_dim, into: %{}, do: {row, build_row(one_dim)}
  end

  def do_game_cycle(cells, size) do
    new_cells = may_revive(cells, size)
    new_cells
  end

  def revive(cells, x, y) do
    update_in(cells, [x, y], fn _ -> @alive end)
  end

  defp build_row(row) do
    for y <- row, into: %{}, do: {y, @dead}
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

    neighbours = two_d_metrics |> Enum.filter(fn m -> m == @alive end) |> length()
    new_val = check_cell(neighbours, cell)

    new_val
  end
end
