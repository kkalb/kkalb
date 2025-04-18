defmodule KkalbWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use KkalbWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      use KkalbWeb, :verified_routes

      import KkalbWeb.ConnCase
      import KkalbWeb.ErrorsOn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import Plug.Conn

      # The default endpoint for testing
      @endpoint KkalbWeb.Endpoint

      # Import conveniences for testing with connections
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Kkalb.Repo)

    if !tags[:async] do
      Sandbox.mode(Kkalb.Repo, {:shared, self()})
    end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Map.put(:secret_key_base, KkalbWeb.Endpoint.config(:secret_key_base))

    {:ok, conn: conn}
  end
end
