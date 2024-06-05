defmodule KkalbWeb.Live.Home do
  @moduledoc """

  """
  require Logger

  use KkalbWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-full w-full">
      <.flash_group flash={@flash} />
      <div class="flex flex-col items-center justify-center gap-y-4 h-full">
        <.nav_button path="/live" text="Portfolio" />
        <.nav_button path="/gameoflife" text="Game of Life" />
      </div>
      <.footer />
    </div>
    """
  end
end
