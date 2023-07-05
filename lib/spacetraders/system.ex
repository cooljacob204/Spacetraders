defmodule Spacetraders.System do
  use Ecto.Schema
  import Ecto.Changeset

  schema "/systems" do
    field :symbol, :string
    field :sector_symbol, :string
    field :type, Ecto.Enum, values: [:NEUTRON_STAR, :RED_STAR, :ORANGE_STAR, :BLUE_STAR, :YOUNG_STAR, :WHITE_DWARF, :BLACK_HOLE, :HYPERGIANT, :NEBULA, :UNSTABLE]
    field :x, :integer
    field :y, :integer
    embeds_many :waypoints, Spacetraders.System.Waypoint
    embeds_many :factions, Spacetraders.System.Faction
  end

  def changeset(system, attrs) do
    system
    |> cast(attrs, [:symbol, :sector_symbol, :type, :x, :y])
    |> validate_required([:symbol, :sector_symbol, :type, :x, :y])
    |> cast_embed(:waypoints, with: &Spacetraders.System.Waypoint.changeset/2)
    |> cast_embed(:factions, with: &Spacetraders.System.Faction.changeset/2)
  end
end
