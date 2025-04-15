defmodule KkalbWeb.Live.Bike.Index do
  @moduledoc """
  A simple game of life implementation to show on a webpage.
  """
  use KkalbWeb, :live_view

  alias Kkalb.Bike.BikeUser
  alias Kkalb.BikeGameController
  alias Kkalb.BikeUsers

  require Logger

  @max_random_number 5

  @impl Phoenix.LiveView
  def mount(_params, %{"bike_user_id" => bike_user_id}, socket) do
    # takes bike_user_id out of cookies and loads the user from the DB
    bike_user = BikeUsers.get_bike_user(bike_user_id)
    bike_users = BikeUsers.list_bike_users()
    {:ok, socket |> assign(bike_user: bike_user, bike_users: bike_users) |> mount_assigns()}
  end

  def mount(_params, _session, socket) do
    # regular mount w/o cookies
    bike_users = BikeUsers.list_bike_users()
    {:ok, socket |> assign(bike_user: nil, bike_users: bike_users) |> mount_assigns()}
  end

  defp mount_assigns(socket),
    do: assign(socket, random_number: :rand.uniform(@max_random_number), tries: 0, indicator: nil, old_highscore: 0)

  @impl Phoenix.LiveView
  def handle_event("save", %{"name" => name}, socket) do
    socket =
      case BikeUsers.get_bike_user_by_name(name) do
        # bike_user does not exist
        nil ->
          changeset = BikeUser.changeset(%BikeUser{highscore: 0, name: name}, %{})

          case BikeUsers.create_bike_user(changeset) do
            {:ok, bike_user} ->
              Logger.info("Successfully created bike user #{bike_user.name}")

              socket |> assign(bike_user: bike_user) |> redirect(to: ~p"/set_user_cookie/#{bike_user.id}")

            # TODO: better error handling
            {:error, %{errors: [name: {"can't be blank", [validation: :required]}]} = _changeset} ->
              socket |> assign(changeset: changeset) |> put_flash(:error, "Please provide a name")

            {:error, changeset} ->
              socket |> assign(changeset: changeset) |> put_flash(:error, "Unknown error")
          end

        # bike_user already exists
        bike_user ->
          Logger.debug("Bike user #{bike_user.name} already exists")

          socket |> assign(bike_user: bike_user) |> redirect(to: ~p"/set_user_cookie/#{bike_user.id}")
      end

    {:noreply, socket}
  end

  def handle_event("save", %{"guessed_number" => guessed_number}, socket) do
    guessed_number = String.to_integer(guessed_number)

    %{
      random_number: random_number,
      tries: tries,
      bike_user: bike_user
    } = socket.assigns

    {tries, indicator} = BikeGameController.guess(guessed_number, random_number, tries)

    new_bike_user = maybe_update_highscore(indicator, bike_user, tries)

    {:noreply,
     assign(socket,
       guessed_number: guessed_number,
       tries: tries,
       indicator: indicator,
       bike_user: new_bike_user,
       old_highscore: bike_user.highscore
     )}
  end

  def handle_event("retry", _, socket) do
    {:noreply, assign(socket, tries: 0, random_number: :rand.uniform(@max_random_number), indicator: nil)}
  end

  def handle_event("logout", _, socket) do
    {:noreply, redirect(socket, to: ~p"/delete_user_cookie/")}
  end

  defp maybe_update_highscore(:too_low, bike_user, _tries), do: bike_user
  defp maybe_update_highscore(:too_high, bike_user, _tries), do: bike_user

  # match means we have a new highscore since there was no highscore until now
  defp maybe_update_highscore(_ind, %{highscore: 0} = bike_user, tries) do
    changeset = BikeUser.changeset(bike_user, %{"highscore" => tries})
    {:ok, bike_user} = BikeUsers.update_bike_user(changeset)
    bike_user
  end

  # highscore beaten
  defp maybe_update_highscore(_ind, %{highscore: highscore} = bike_user, tries) when highscore > tries do
    changeset = BikeUser.changeset(bike_user, %{"highscore" => tries})
    {:ok, bike_user} = BikeUsers.update_bike_user(changeset)
    Logger.info("NEW HIGHSCORE #{to_string(tries)} SAVED")
    bike_user
  end

  # highscore unbeaten
  defp maybe_update_highscore(_ind, %{highscore: highscore} = bike_user, _tries) do
    Logger.info("HIGHSCORE #{to_string(highscore)} NOT BEATEN")
    bike_user
  end

  defp render_result(%{bike_user: nil} = assigns), do: ~H""

  defp render_result(%{indicator: indicator, tries: tries, bike_user: _bike_user, old_highscore: old_highscore} = assigns) do
    result = BikeGameController.game_result_to_html(indicator, tries, old_highscore)

    assigns = assign(assigns, result: result)

    ~H"""
    <.header text="">
      {raw(@result)}
    </.header>
    """
  end

  # this is mainly for debugging, comment out if not needed
  def render_table(assigns) do
    ~H"""
    <div class="flex justify-center items-center mt-4">
      <div class="overflow-x-auto bg-csilver">
        <table class="min-w-full divide-y divide-gray-200 shadow-md rounded-xl overflow-hidden bg-csilver">
          <thead class="bg-csilver">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-cwhite uppercase tracking-wider">
                Name
              </th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-cwhite uppercase tracking-wider">
                Highscore
              </th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-cwhite uppercase tracking-wider">
                Actions (WIP)
              </th>
            </tr>
          </thead>
          <tbody class="bg-csilver divide-y divide-gray-100">
            <%= for user <- @bike_users do %>
              <tr class="hover:bg-cgray transition-all duration-150">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-cwhite">{user.name}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-cwhite">{user.highscore}</td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                  <button class="text-blue-500 inline-flex items-center space-x-1">
                    <.icon name="hero-pencil-square" class="h-4 w-4" />
                    <span>Edit</span>
                  </button>
                  <button class="text-red-500 inline-flex items-center space-x-1">
                    <.icon name="hero-trash" class="h-4 w-4" />
                    <span>Delete</span>
                  </button>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
