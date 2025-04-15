defmodule KkalbWeb.Live.Bike.Index do
  @moduledoc """
  A simple game of life implementation to show on a webpage.
  """
  use KkalbWeb, :live_view

  alias Kkalb.Bike.BikeUser
  alias Kkalb.BikeUsers

  require Logger

  @random_range 5

  @impl Phoenix.LiveView
  def mount(_params, %{"bike_user_id" => bike_user_id}, socket) do
    # takes bike_user_id out of cookies and loads the user from the DB
    bike_user = BikeUsers.get_bike_user(bike_user_id)
    {:ok, socket |> assign(bike_users: [], bike_user: bike_user) |> mount_assigns()}
  end

  def mount(_params, _session, socket) do
    # regular mount w/o cookies
    {:ok, socket |> assign(bike_user: nil) |> mount_assigns()}
  end

  defp mount_assigns(socket), do: assign(socket, random_number: :rand.uniform(@random_range), tries: 0, indicator: nil)

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

            {:error, changeset} ->
              Logger.error(to_string(changeset.errors))
              assign(socket, changeset: changeset)
          end

        # bike_user already exists
        bike_user ->
          Logger.debug("Bike user #{bike_user.name} already exists")

          assign(socket, bike_user: bike_user)
      end

    {:noreply, socket}
  end

  def handle_event("save", %{"guessed_number" => guessed_number}, socket) do
    guessed_number = String.to_integer(guessed_number)
    random_number = socket.assigns.random_number
    tries = socket.assigns.tries
    bike_user = socket.assigns.bike_user

    {tries, indicator, bike_user} =
      cond do
        guessed_number > random_number ->
          {tries + 1, "too high", bike_user}

        guessed_number < random_number ->
          {tries + 1, "too low", bike_user}

        true ->
          bike_user = socket.assigns.bike_user
          bike_user = maybe_update_highscore(bike_user, tries, bike_user.highscore)

          {tries + 1, "a match", bike_user}
      end

    {:noreply, assign(socket, guessed_number: guessed_number, tries: tries, indicator: indicator, bike_user: bike_user)}
  end

  def handle_event("retry", _, socket) do
    {:noreply, assign(socket, tries: 0, random_number: :rand.uniform(@random_range), indicator: nil)}
  end

  defp maybe_update_highscore(bike_user, tries, 0) do
    changeset = BikeUser.changeset(bike_user, %{"highscore" => tries + 1})
    {:ok, bike_user} = BikeUsers.update_bike_user(changeset)
    bike_user
  end

  defp maybe_update_highscore(bike_user, tries, highscore) when highscore > tries do
    changeset = BikeUser.changeset(bike_user, %{"highscore" => tries + 1})
    {:ok, bike_user} = BikeUsers.update_bike_user(changeset)
    Logger.info("NEW HIGHSCORE #{to_string(tries + 1)} SAVED")
    bike_user
  end

  defp maybe_update_highscore(bike_user, _tries, highscore) do
    Logger.info("HIGHSCORE #{to_string(highscore)} NOT BEATEN")
    bike_user
  end
end
