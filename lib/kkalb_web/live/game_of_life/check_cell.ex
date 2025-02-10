defmodule KkalbWeb.Live.GameOfLife.CheckCell do
  @moduledoc """
  Define functions at compile time.

  Note that @dead and @alive are inserted from the importing file and
  thus the calling order is important.
  """
  defmacro define_check_cell do
    quote do
      defp check_cell(neighbours, _) when neighbours < 2, do: @dead
      defp check_cell(neighbours, @alive) when neighbours in [2, 3], do: @alive
      defp check_cell(neighbours, @alive) when neighbours > 3, do: @dead
      defp check_cell(3, @dead), do: @alive
      defp check_cell(_, cell), do: cell
    end
  end
end
