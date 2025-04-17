defmodule KkalbWeb.GameOfLife.CheckCellTest do
  use KkalbWeb.FeatureCase, async: false

  defmodule MacroModule do
    @moduledoc false
    import KkalbWeb.Live.GameOfLife.CheckCell

    # does not matter if we use int or atom here so instead of int, we go for atom for better readablity
    @dead :dead
    @alive :alive

    define_check_cell()

    def public_check(neighbours, cell), do: check_cell(neighbours, cell)
  end

  describe "check_cell/2" do
    test "returns :dead when fewer than 2 neighbours (underpopulation)" do
      assert MacroModule.public_check(0, :alive) == :dead
      assert MacroModule.public_check(1, :alive) == :dead
    end

    test "returns :alive when 2 or 3 neighbours and cell is alive (survival)" do
      assert MacroModule.public_check(2, :alive) == :alive
      assert MacroModule.public_check(3, :alive) == :alive
    end

    test "returns :dead when more than 3 neighbours and cell is alive (overpopulation)" do
      assert MacroModule.public_check(4, :alive) == :dead
      assert MacroModule.public_check(5, :alive) == :dead
    end

    test "returns :alive when exactly 3 neighbours and cell is dead (reproduction)" do
      assert MacroModule.public_check(3, :dead) == :alive
    end

    test "returns cell unchanged in all other cases" do
      assert MacroModule.public_check(2, :dead) == :dead
      assert MacroModule.public_check(4, :dead) == :dead
    end
  end
end
