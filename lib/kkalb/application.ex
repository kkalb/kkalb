defmodule Kkalb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # when debug is set, all oban logs will be written to the default logger as debug logs.
    # _ = Oban.Telemetry.attach_default_logger(level: :debug)

    repo = if Mix.env() == :prod, do: [], else: [Kkalb.Repo]

    children =
      [
        # Start the PubSub system
        {Phoenix.PubSub, name: Kkalb.PubSub},
        # Start Finch
        {Finch, name: Kkalb.Finch},
        # Start the Endpoint (http/https)
        KkalbWeb.Endpoint,
        # {Oban, Application.fetch_env!(:kkalb, Oban)},
        Kkalb.Scheduler,
        Kkalb.EtsIssuesGenServer
      ] ++ repo

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kkalb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KkalbWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
