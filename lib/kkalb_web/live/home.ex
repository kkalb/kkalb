defmodule KkalbWeb.Live.Home do
  @moduledoc """
  Landing page of the webside.
  """
  use KkalbWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
