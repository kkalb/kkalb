defmodule KkalbWeb.Live.Home do
  @moduledoc """
  Landing page of the webside.
  """
  use KkalbWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    journey = [
      %{id: 0, title: "Caregiving", date: "2024 - now ", text: "Caregiving for a direct relative. Since this ended now,
        I am happy to be back in tech."},
      %{
        id: 1,
        title: "Sr. Software Engineer - Team Internet",
        date: "2023 - 2024",
        text: "Elixir-driven AI for proper advertising.
        \"Placeholder for future text enforcing a larger text block for developing\""
      },
      %{
        id: 2,
        title: "Sr. Software Engineer - Aponia",
        date: "2021 - 2023",
        text: "Front- and backend developer, implementing stateof-the-art Git/SCM and SCRUM processes.
      Implementing, improvement and supervising of a
      CI/CD pipeline as a DevOps engineer."
      },
      %{
        id: 3,
        title: "Software Engineer - GE Additive",
        date: "2019 - 2021",
        text: "Building software to assess the quality of the melting
      process (QMMeltpool3D). Creation of intermediate
      API wrapping software as a man-in-the-middle for
      different systems inside the additive ecosystem."
      },
      %{
        id: 4,
        title: "Software Engineer - Hans Weber",
        date: "2018 - 2019",
        text: "Optimization of a PID controller for a temperature
      control loop of an extruder. Creating frontend for
      reading and writing OPC UA API variables. Analysis
      and evaluation of the complete control loop."
      },
      %{
        id: 5,
        title: "Software Engineer - Loewe Technology",
        date: "2017",
        text: "Creation of C# software for communication between
      oscilloscopes via OOP, GUI and VISA driver creation.
      Translated a Visual Basic driver to C# for
      communication with an AC source."
      },
      %{
        id: 6,
        title: "Bachelor of Engineering",
        date: "2015 - 2019",
        text: "Electrical Engineering, Automation and Robotics"
      },
      %{
        id: 7,
        title: "In development",
        date: "20av - 20xy",
        text: "Some dummy for more content for developing"
      }
    ]

    focus = 1
    {:ok, assign(socket, focus: focus, journey: journey)}
  end

  @impl Phoenix.LiveView
  def handle_event("download_portfolio", _assigns, socket) do
    {:noreply, redirect(socket, to: "/download_portfolio")}
  end

  @impl Phoenix.LiveView
  def handle_event("focus", %{"id" => id}, socket) do
    {:noreply, assign(socket, focus: String.to_integer(id))}
  end

  attr :title, :string, required: true
  attr :date, :string, required: true
  attr :id, :integer, required: true
  attr :focus, :integer, required: true
  slot :inner_block, required: true

  def right_row(assigns) do
    ~H"""
    <div class="grid grid-cols-4 justify-center items-center place-items-center w-full h-full">
      <div class="col-span-1 col-start-1" />
      <.divider date={@date} focus={@focus == @id} dir="right" />
      <.textblock title={@title} id={@id} focus={@focus}>
        {render_slot(@inner_block)}
      </.textblock>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :id, :integer, required: true
  attr :focus, :boolean, required: true
  slot :inner_block, required: true

  def textblock(assigns) do
    focused? = assigns.id == assigns.focus
    cond_class = if focused?, do: "text-cwhite w-3/4", else: "text-cwhite/50 w-2/4 hover:animate-pulse"
    assigns = assign(assigns, cond_class: cond_class, focused?: focused?)

    ~H"""
    <button
      phx-click="focus"
      phx-value-id={@id}
      class={[
        "sm:block col-span-2 p-4 pt-2 mb-4 bg-cgray/80 border border-corange/50 text-cwhite rounded-md sm:mr-8 mr-2",
        @cond_class
      ]}
    >
      <p :if={not @focused?} class="font-normal text-normal whitespace-normal mb-2">
        {@title}
      </p>
      <p :if={@focused?} class="font-bold text-xl whitespace-normal mb-2">
        {@title}
      </p>
      <p :if={not @focused?} class="whitespace-normal text-xs">
        {render_slot(@inner_block)}
      </p>
      <p :if={@focused?} class="whitespace-normal">
        {render_slot(@inner_block)}
      </p>
    </button>
    """
  end

  attr :date, :string, required: true
  attr :focus, :boolean, required: true
  attr :dir, :string, required: true

  def divider(assigns) do
    text_color = if assigns.focus, do: "text-cwhite", else: "text-cwhite/20"
    bg_color = if assigns.focus, do: "bg-cwhite", else: "bg-cwhite/20"
    width = if assigns.focus, do: "w-1", else: "w-0.5"
    circle = if assigns.focus, do: "w-5 h-5", else: "w-4 h-4"

    assigns =
      assign(assigns,
        text_color: text_color,
        bg_color: bg_color,
        width: width,
        circle: circle
      )

    ~H"""
    <div class={["flex items-center flex-col h-full whitespace-nowrap", @text_color]}>
      <div class="flex flex-row items-center">
        <div :if={@dir == "right"} class="absolute">
          <p class={["relative right-24"]}>{@date}</p>
        </div>
        <div class={["relative rounded-[50%]", @bg_color, @circle]} />
      </div>
      <div class={["h-full my-2", @bg_color, @width]}></div>
    </div>
    """
  end
end
