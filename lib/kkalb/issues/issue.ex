defmodule Kkalb.Issues.Issue do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "issues" do
    field(:id, :decimal, primary_key: true)
    field(:number, :integer)
    field(:gh_created_at, :utc_datetime)
    field(:gh_updated_at, :utc_datetime)
    field(:gh_closed_at, :utc_datetime)
    timestamps()
  end

  @doc false
  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:id, :number, :gh_created_at, :gh_updated_at, :gh_closed_at])
    |> validate_required([:id, :number, :gh_created_at])
  end
end
