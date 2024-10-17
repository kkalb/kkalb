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
  def handle_event("download_portfolio", _assigns, socket) do
    {:noreply, redirect(socket, to: "/download_portfolio")}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-full w-full overflow-auto">
      <.header text="Portfolio - WIP"></.header>
      <.button type="button" phx-click="download_portfolio" class="absolute top-2 right-1 sm:right-8">
        <span>Download Portfolio</span>
      </.button>
      <.left_row title="Caregiving" date="2024 - now ">
        Caregiving for a direct relative. Since this ended now,
        I am happy to be back in tech.
      </.left_row>

      <.right_row title="Sr. Software Engineer - Team Internet" date="2023 - 2024">
        Elixir-driven AI for proper advertising
      </.right_row>

      <.left_row title="Sr. Software Engineer - Aponia" date="2021 - 2023">
        Front- and backend developer, implementing stateof-the-art Git/SCM and SCRUM processes.
        Implementing, improvement and supervising of a
        CI/CD pipeline as a DevOps engineer.
      </.left_row>

      <.right_row title="Software Engineer - GE Additive" date="2019 - 2021">
        Building software to assess the quality of the melting
        process (QMMeltpool3D). Creation of intermediate
        API wrapping software as a man-in-the-middle for
        different systems inside the additive ecosystem.
      </.right_row>

      <.left_row title="Sr. Software Engineer - Hans Weber" date="2018 - 2019">
        Optimization of a PID controller for a temperature
        control loop of an extruder. Creating frontend for
        reading and writing OPC UA API variables. Analysis
        and evaluation of the complete control loop
      </.left_row>

      <.right_row title="Bachelor of Engineering" date="2015 - 2019">
        Electrical Engineering, Automation and Robotics
      </.right_row>

      <.left_row title="Software Engineer - Loewe Technology" date="2017">
        Creation of C# software for communication between
        oscilloscopes via OOP, GUI and VISA driver creation.
        Translated a Visual Basic driver to C# for
        communication with an AC source
      </.left_row>
      <.footer />
    </div>
    """
  end

  attr :title, :string, required: true
  attr :date, :string, required: true
  slot :inner_block, required: true

  def left_row(assigns) do
    ~H"""
    <div class="grid grid-cols-9 justify-center items-center place-items-center w-full h-full">
      <.textblock title={@title} class="md:ml-24 ml-4">
        <%= render_slot(@inner_block) %>
      </.textblock>
      <.divider date={@date} dir="left" />
      <div />
    </div>
    """
  end

  attr :title, :string, required: true
  attr :date, :string, required: true
  slot :inner_block, required: true

  def right_row(assigns) do
    ~H"""
    <div class="grid grid-cols-9 justify-center items-center place-items-center w-full h-full">
      <div class="col-span-4 col-start-1" />
      <.divider date={@date} dir="right" />
      <.textblock title={@title} class="sm:mr-8 mr-0">
        <%= render_slot(@inner_block) %>
      </.textblock>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :class, :string, required: false
  slot :inner_block, required: true

  def textblock(assigns) do
    ~H"""
    <div class={[
      "sm:block col-span-4 p-4 pt-2 mb-4 bg-cgray/80 border border-corange/50 text-cwhite rounded-md max-w-screen-sm",
      @class
    ]}>
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
  attr :dir, :string, required: true

  def divider(assigns) do
    ~H"""
    <div class="flex items-center flex-col text-cwhite h-full whitespace-nowrap">
      <div class="flex flex-row items-center">
        <div :if={@dir == "right"} class="absolute">
          <div class="relative right-24"><%= @date %></div>
        </div>
        <div class="relative bg-cwhite/80 w-4 h-4 rounded-[50%]" />
        <div :if={@dir == "left"} class="absolute">
          <div class="relative left-8"><%= @date %></div>
        </div>
      </div>
      <div class="bg-cwhite w-0.5 h-full my-2"></div>
    </div>
    """
  end
end
