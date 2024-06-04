defmodule Kkalb.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Kkalb.Repo

      import Ecto
      import Ecto.Query
      import Kkalb.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Kkalb.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Kkalb.Repo, {:shared, self()})
    end

    :ok
  end
end
