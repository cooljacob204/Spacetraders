defmodule Spacetraders.Repo.Migrations.CreateSystems do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"

    create table(:systems) do
      add :symbol, :string, null: false
      add :sector_symbol, :string, null: false
      add :type, :string, null: false
      add :factions, :jsonb, null: false

      timestamps(default: fragment("NOW()"))
    end
    execute("SELECT AddGeometryColumn('systems', 'position', 3857, 'POINT', 2);")
    create index(:systems, [:symbol], unique: true)
  end

  def down do
    drop table(:systems)

    execute "DROP EXTENSION IF EXISTS postgis"
  end
end
