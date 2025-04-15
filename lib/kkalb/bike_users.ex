defmodule Kkalb.BikeUsers do
  @moduledoc """
  Context module for bike users.
  """

  import Ecto.Query

  alias Kkalb.Bike.BikeUser
  alias Kkalb.Repo

  @doc """
  Returns the list of bike_users.
  Default limit is 5.
  Orders ascendending by highscore and leaves out users w/o highscore.

  ## Examples

      iex> BikeUsers.list_bike_users()
      [%BikeUser{}]

  """
  @spec list_bike_users(limit :: integer()) :: [BikeUser.t()]
  def list_bike_users(limit \\ 5) do
    query =
      from(bu in BikeUser, order_by: [asc: bu.highscore], limit: ^limit, where: bu.highscore != 0)

    Repo.all(query)
  end

  @doc """
  Returns bike user by id.

  ## Examples

      iex> BikeUsers.get_bike_user("1234")
      %BikeUser{}

  """
  @spec get_bike_user(binary()) :: BikeUser.t() | nil
  def get_bike_user(id) do
    Repo.get(BikeUser, id)
  end

  @doc """
  Returns bike user by name.

  ## Examples

      iex> BikeUsers.get_bike_user_by_name("bravo")
      %BikeUser{}

  """
  @spec get_bike_user_by_name(binary()) :: BikeUser.t() | nil
  def get_bike_user_by_name(name) do
    query =
      from(bu in BikeUser, where: bu.name == ^name)

    Repo.one(query)
  end

  @doc """
  Create a new user with a changeset.

  ## Examples

      iex> BikeUsers.create_bike_user(changeset)
      {:ok, %BikeUser{}}

  """
  @spec create_bike_user(Ecto.Changeset.t()) :: {:ok, BikeUser.t()} | {:error, Ecto.Changeset.t()}
  def create_bike_user(bike_user) do
    Repo.insert(bike_user)
  end

  @doc """
  Updates an existing user with a changeset.

  ## Examples

      iex> BikeUsers.update_bike_user(changeset)
      {:ok, %BikeUser{}}

  """
  @spec update_bike_user(Ecto.Changeset.t()) :: {:ok, BikeUser.t()} | {:error, Ecto.Changeset.t()}
  def update_bike_user(bike_user) do
    Repo.update(bike_user)
  end
end
