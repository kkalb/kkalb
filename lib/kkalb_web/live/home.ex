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

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-full w-full">
      <.header text="Portfolio"></.header>
      <.left_row title="Caregiving" date="2024-now">
        Caregiving for a direct relative
      </.left_row>
      <.right_row title="Sr. Software Engineer - Team Internet" date="2023-2024">
        Elixir-driven AI for proper advertising
      </.right_row>
      <.left_row title="Sr. Software Engineer - Aponia" date="2021-2023">
        Front- und Backend-Developer, State-of-the-art Git/SCM und Scrum-Prozesse einführen.
        Verbesserung, Überwachung und Implementierung der
        CI/CD-Pipeline als DevOps-Engineer
      </.left_row>

      <.right_row title="Software Engineer - GE Additive" date="2019-2021">
        Elixir-driven AI for proper advertising
      </.right_row>

      <.left_row title="Sr. Software Engineer - Hans Weber" date="2018-2019">
        Optimierung eines PID-Reglers für eine Temperatur-Regelstrecke
        eines Extruders. Entwurf der Kommunikations-Software
        nach OPC-UA-Standard und Analyse des Gesamtregelkreises.
      </.left_row>

      <.right_row title="Bachelor of Engineering" date="2015-2019">
        Electrical Engineering, Automation and Robotics
      </.right_row>

      <.footer />
    </div>
    """
  end

  attr :title, :string, required: true
  attr :date, :string, required: true
  slot :inner_block, required: true

  def left_row(assigns) do
    ~H"""
    <div class="grid grid-cols-9 justify-center items-center w-full h-full">
      <.textblock title={@title}>
        <%= render_slot(@inner_block) %>
      </.textblock>
      <.divider date={@date} />
      <div />
    </div>
    """
  end

  attr :title, :string, required: true
  attr :date, :string, required: true
  slot :inner_block, required: true

  def right_row(assigns) do
    ~H"""
    <div class="grid grid-cols-9 justify-center items-center mr-4 w-full h-full">
      <div class="col-span-4 col-start-1" />
      <.divider date={@date} />
      <.textblock title={@title}>
        <%= render_slot(@inner_block) %>
      </.textblock>
    </div>
    """
  end

  attr :title, :string, required: true
  slot :inner_block, required: true

  def textblock(assigns) do
    ~H"""
    <div class="sm:block col-span-4 md:ml-24 ml-4 p-4 pt-2 bg-cgray/80 border border-corange/50 text-cwhite rounded-md max-w-screen-sm overflow-none">
      <p class="font-bold text-xl whitespace-normal mb-2">
        <%= @title %>
      </p>
      <p class="whitespace-normal">
        <%= render_slot(@inner_block) %>
      </p>
    </div>
    """
  end

  attr :date, :string, required: true

  def divider(assigns) do
    ~H"""
    <div class="flex flex-col items-center text-cwhite h-full whitespace-normal">
      <%= @date %>
      <div class="flex items-center bg-cwhite w-[2px] h-full my-2"></div>
    </div>
    """
  end
end
