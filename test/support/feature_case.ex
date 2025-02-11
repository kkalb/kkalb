defmodule KkalbWeb.FeatureCase do
  @moduledoc false
  use ExUnit.CaseTemplate
  use Wallaby.DSL

  using do
    quote do
      use Wallaby.Feature

      import Ecto
      import Ecto.Query
      import KkalbWeb.ErrorsOn
      import Wallaby.Query

      alias Kkalb.Repo

      @endpoint KkalbWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, session} = Wallaby.start_session()
    {:ok, session: session}
  end
end
