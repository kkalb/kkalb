defmodule Kkalb.Repo.Migrations.AddBikeUser do
  @moduledoc false
  use Ecto.Migration

  def up do
    create table(:bike_users, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)
      add(:highscore, :integer, null: false)

      timestamps()
    end

    create(unique_index(:bike_users, [:name]))
  end

  def down do
    drop(index(:bike_users, [:name]))
    drop(table(:bike_users))
  end
end
