defmodule Kkalb.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      import Ecto
      import Ecto.Query
      import Kkalb.RepoCase
      import KkalbWeb.ErrorsOn

      alias Kkalb.Repo
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Kkalb.Repo)

    if !tags[:async] do
      Sandbox.mode(Kkalb.Repo, {:shared, self()})
    end

    :ok
  end
end
