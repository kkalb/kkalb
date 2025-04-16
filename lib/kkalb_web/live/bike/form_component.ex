defmodule KkalbWeb.Live.Bike.FormComponent do
  @moduledoc false
  use KkalbWeb, :live_component

  def render(%{bike_user: nil} = assigns) do
    ~H"""
    <div class="flex justify-center w-full">
      <.form :let={form} for={%{}} phx-submit="save" class="w-3/4 space-y-4">
        <.input field={form[:name]} label="Name" />
        <.button
          phx-disable-with="Saving..."
          class="w-full bg-blue-600 hover:bg-blue-700 text-cwhite font-semibold py-2 px-4 rounded-lg transition duration-200"
        >
          Login
        </.button>
      </.form>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center w-full">
      <.form :let={_form} for={%{}} phx-submit="save" class="w-3/4 space-y-4">
        <.input
          label={"The target number is between 1 and #{@max_random_number}"}
          id="guessed_number"
          type="number"
          name="guessed_number"
          value={@guessed_number}
        />

        <%= if @indicator != :match do %>
          <.button
            phx-disable-with="Saving..."
            class="w-full bg-blue-600 hover:bg-blue-700 text-cdark font-semibold py-2 px-4 rounded-lg transition duration-200"
          >
            Guess
          </.button>
        <% else %>
          <.button
            type="button"
            phx-click="retry"
            class="w-full text-cdark font-semibold py-2 px-4 rounded-lg transition duration-200"
          >
            Retry
          </.button>
        <% end %>
      </.form>
    </div>
    """
  end
end
