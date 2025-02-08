defmodule Kkalb.Issues.IssueTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset

  alias Kkalb.Issues.Issue

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        value =
          case value do
            [value | _] -> value
            _ -> value
          end

        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp issue_struct do
    %Issue{
      id: Decimal.new("1"),
      number: 123,
      gh_created_at: ~U[2023-01-01 00:00:00Z],
      gh_updated_at: ~U[2023-01-01 01:00:00Z],
      gh_closed_at: nil,
      inserted_at: ~N[2023-01-01 02:00:00],
      updated_at: ~N[2023-01-01 03:00:00]
    }
  end

  describe "changeset/2" do
    @valid_attrs %{
      id: Decimal.new("1"),
      number: 123,
      gh_created_at: ~U[2023-01-01 00:00:00Z],
      gh_updated_at: ~U[2023-01-01 01:00:00Z],
      gh_closed_at: nil
    }

    test "valid attributes" do
      changeset = Issue.changeset(issue_struct(), @valid_attrs)

      assert changeset.valid?
      assert get_field(changeset, :id) == Decimal.new("1")
      assert get_field(changeset, :number) == 123
      assert get_field(changeset, :gh_created_at) == ~U[2023-01-01 00:00:00Z]
      assert get_field(changeset, :gh_closed_at) == nil
    end

    test "negative number field" do
      changeset = Issue.changeset(issue_struct(), Map.put(@valid_attrs, :number, -1))

      refute changeset.valid?
      assert %{number: ["must be greater than or equal to 0"]} = errors_on(changeset)
    end

    test "invalid datetime format" do
      changeset = Issue.changeset(issue_struct(), Map.put(@valid_attrs, :gh_created_at, "invalid-date"))

      refute changeset.valid?
      assert %{gh_created_at: [_]} = errors_on(changeset)
    end

    test "unstrict type checks, coverting integer to decimal" do
      changeset = Issue.changeset(issue_struct(), Map.put(@valid_attrs, :id, 1))

      assert changeset.valid?
      assert get_field(changeset, :id) == Decimal.new("1")
    end
  end

  # Optional Property-Based Tests with StreamData
  describe "property-based tests" do
    use ExUnitProperties

    property "random id as decimal" do
      check all id <- StreamData.non_negative_integer() do
        attrs = Map.put(@valid_attrs, :id, Decimal.new(1, id, 0))
        changeset = Issue.changeset(issue_struct(), attrs)

        assert changeset.valid?
        assert get_field(changeset, :id) == Decimal.new(id)
      end
    end
  end
end
