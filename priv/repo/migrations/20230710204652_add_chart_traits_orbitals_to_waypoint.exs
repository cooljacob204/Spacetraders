defmodule Spacetraders.Repo.Migrations.AddChartTraitsOrbitalsFactionToWaypoint do
  use Ecto.Migration

  def change do
    alter table(:waypoints) do
      add :chart, :jsonb
      add :traits, :jsonb
      add :orbitals, :jsonb
      add :faction, :jsonb
    end
  end
end
