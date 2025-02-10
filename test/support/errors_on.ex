defmodule KkalbWeb.ErrorsOn do
  @moduledoc """
  Translates changeset errors to error strings for testing.
  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        value = get_value(value)

        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp get_value(value) do
    case value do
      [value | _] -> value
      _ -> value
    end
  end
end
