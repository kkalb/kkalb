defmodule Kkalb.Repo.Migrations.CreateIssues do
  @moduledoc false
  use Ecto.Migration

  def up do
    create table(:issues, primary_key: false) do
      add(:id, :decimal, primary_key: true)
      add(:number, :integer, null: false)
      add(:gh_created_at, :utc_datetime, null: false)
      add(:gh_updated_at, :utc_datetime)
      add(:gh_closed_at, :utc_datetime)
      timestamps()
    end
  end

  def down do
    drop(table(:issues))
  end
end
