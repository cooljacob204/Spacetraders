defmodule Spacetraders.Repo.Migrations.CreateWaypoints do
  use Ecto.Migration

  def up do
    create table(:waypoints) do
      add :symbol, :string, null: false
      add :type, :string, null: false
      add :system_id, references(:systems, on_delete: :delete_all), null: false

      timestamps(default: fragment("NOW()"))
    end

    execute("SELECT AddGeometryColumn('waypoints', 'position', 3857, 'POINT', 2);")
    create index(:waypoints, [:system_id])
    create index(:waypoints, [:symbol], unique: true)
  end

  def down do
    drop table(:waypoints)
  end
end
