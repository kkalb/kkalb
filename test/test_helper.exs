{:ok, _} = Application.ensure_all_started(:wallaby)
Application.ensure_all_started(:kkalb)
Application.put_env(:wallaby, :base_url, KkalbWeb.Endpoint.url())
ExUnit.start()
