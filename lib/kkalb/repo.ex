defmodule Kkalb.Repo do
  use Ecto.Repo,
    otp_app: :kkalb,
    adapter: Ecto.Adapters.Postgres
end
