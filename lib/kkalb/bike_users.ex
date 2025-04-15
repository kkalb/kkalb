defmodule Kkalb.BikeUsers do
  @moduledoc """
  Context module for bike users.
  """

  import Ecto.Query

  alias Kkalb.Bike.BikeUser
  alias Kkalb.Repo

  @doc """
  Returns the list of bike_users.

  ## Examples

      iex> BikeUsers.list_bike_users()
      [%BikeUser{}}

  """
  @spec list_bike_users() :: [BikeUser.t()]
  def list_bike_users do
    query =
      from(i in BikeUser)

    Repo.all(query)
  end

  @spec get_bike_user(binary()) :: BikeUser.t() | nil
  def get_bike_user(id) do
    Repo.get(BikeUser, id)
  end

  @spec get_bike_user_by_name(binary()) :: BikeUser.t() | nil
  def get_bike_user_by_name(name) do
    query =
      from(bu in BikeUser, where: bu.name == ^name)

    Repo.one(query)
  end

  @spec create_bike_user(Ecto.Changeset.t()) :: {:ok, BikeUser.t()} | {:error, Ecto.Changeset.t()}
  def create_bike_user(bike_user) do
    Repo.insert(bike_user)
  end

  @spec update_bike_user(Ecto.Changeset.t()) :: {:ok, BikeUser.t()} | {:error, Ecto.Changeset.t()}
  def update_bike_user(bike_user) do
    Repo.update(bike_user)
  end
end
