defmodule Spacetraders.Repo.Migrations.CreateLanes do
  use Ecto.Migration

  def change do
    create table(:lanes) do
      add :jump_system_id, references(:systems, on_delete: :delete_all)
      add :arrival_system_id, references(:systems, on_delete: :delete_all)
      add :distance, :float

      timestamps()
    end

    create index(:lanes, [:jump_system_id])
    create index(:lanes, [:arrival_system_id])
    create index(:lanes, [:jump_system_id, :arrival_system_id], unique: true)
  end
end
