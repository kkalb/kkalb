defmodule Kkalb.Issues.Issue do
  @moduledoc """
  Schema for Issue.
  Typically an issue comes from the GitHub-Api.
  """
  use TypedEctoSchema

  import Ecto.Changeset

  @primary_key false
  typed_schema "issues" do
    field(:id, :decimal, primary_key: true, enforce: true, null: false)
    field(:number, :integer, enforce: true, null: false) :: non_neg_integer()
    field(:gh_created_at, :utc_datetime, enforce: true, null: false) :: DateTime.t()
    field(:gh_updated_at, :utc_datetime, enforce: true, null: false) :: DateTime.t()
    field(:gh_closed_at, :utc_datetime, enforce: true, null: true) :: DateTime.t() | nil
    timestamps(type: :naive_datetime_usec)
  end

  @doc false
  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:id, :number, :gh_created_at, :gh_updated_at, :gh_closed_at])
    |> validate_required([:id, :number, :gh_created_at])
    |> validate_number(:number, greater_than_or_equal_to: 0)
  end
end
