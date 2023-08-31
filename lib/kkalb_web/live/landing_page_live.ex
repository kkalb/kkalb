defmodule KkalbWeb.Live.LandingPageLive do
  @moduledoc """

  """
  use KkalbWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign(socket, session: session)
    IO.puts("asopmjdpa+s")
    {:ok, socket |> assign(session: session) |> push_redirect(to: "/live")}
  end

  @impl true
  def render(_socket) do
    assigns = %{}

    ~H"""
    <div></div>
    """
  end
end
