defmodule Kkalb.Bike.BikeUser do
  @moduledoc """
  Schema for BikeUser.
  """
  use TypedEctoSchema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  typed_schema "bike_users" do
    field(:highscore, :integer, enforce: true, null: false) :: non_neg_integer()
    field(:name, :string, enforce: true, null: false) :: binary()
    timestamps()
  end

  @doc false
  def changeset(bike_user, attrs) do
    bike_user
    |> cast(attrs, [:highscore, :name])
    |> validate_required([:highscore, :name])
  end
end
