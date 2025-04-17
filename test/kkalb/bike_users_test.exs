defmodule Kkalb.BikeUsersTest do
  use Kkalb.RepoCase, async: false

  alias Kkalb.Bike.BikeUser
  alias Kkalb.BikeUsers

  setup do
    {:ok, first_bike_user} =
      %BikeUser{highscore: 1, name: "first_user"}
      |> BikeUser.changeset(%{})
      |> BikeUsers.create_bike_user()

    {:ok, second_bike_user} =
      %BikeUser{highscore: 2, name: "second_user"}
      |> BikeUser.changeset(%{})
      |> BikeUsers.create_bike_user()

    {:ok, third_bike_user} =
      %BikeUser{highscore: 3, name: "third_user"}
      |> BikeUser.changeset(%{})
      |> BikeUsers.create_bike_user()

    {:ok, first_bike_user: first_bike_user, second_bike_user: second_bike_user, third_bike_user: third_bike_user}
  end

  test "list_bike_users/1 returns three users" do
    bike_users = BikeUsers.list_bike_users()
    assert Enum.count(bike_users) == 3
  end

  test "get_bike_user/1 by id", %{first_bike_user: first_bike_user} do
    first_bike_user_queried = BikeUsers.get_bike_user(first_bike_user.id)

    assert first_bike_user_queried == first_bike_user
  end

  test "get_bike_user/1 by invalid id" do
    nil = BikeUsers.get_bike_user(Ecto.UUID.autogenerate())
  end

  test "get_bike_user/1 by name", %{first_bike_user: first_bike_user} do
    first_bike_user_queried = BikeUsers.get_bike_user_by_name(first_bike_user.name)

    assert first_bike_user_queried == first_bike_user
  end

  test "get_bike_user/1 by invalid name" do
    nil = BikeUsers.get_bike_user_by_name("invalid_name")
  end

  test "create_bike_user/2 when already existing triggers unique contraint", %{first_bike_user: _first_bike_user} do
    {:error, changeset} =
      %BikeUser{highscore: 1, name: "first_user"}
      |> BikeUser.changeset(%{})
      |> BikeUsers.create_bike_user()

    assert [{:name, {"has already been taken", [constraint: :unique, constraint_name: "bike_users_name_index"]}}] =
             changeset.errors
  end

  test "update_bike_user/1 with valid changeset", %{second_bike_user: second_bike_user} do
    {:ok, second_bike_user} =
      second_bike_user
      |> BikeUser.changeset(%{highscore: 1})
      |> BikeUsers.update_bike_user()

    assert %BikeUser{highscore: 1, name: "second_user"} = second_bike_user
  end

  test "update_bike_user/1 with invalid changeset catched by validation", %{first_bike_user: first_bike_user} do
    {:error, changeset} =
      first_bike_user
      |> BikeUser.changeset(%{name: ""})
      |> BikeUsers.update_bike_user()

    assert [name: {"can't be blank", [validation: :required]}] = changeset.errors
  end
end
