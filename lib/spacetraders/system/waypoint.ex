defmodule Spacetraders.System.Waypoint do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :symbol, :string
    field :type, Ecto.Enum, values: [:PLANET, :GAS_GIANT, :MOON, :ORBITAL_STATION, :JUMP_GATE, :ASTEROID_FIELD, :NEBULA, :DEBRIS_FIELD, :GRAVITY_WELL]
    field :x, :integer
    field :y, :integer
  end

  def changeset(waypoint, attrs) do
    waypoint
    |> cast(attrs, [:symbol, :type, :x, :y])
    |> validate_required([:symbol, :type, :x, :y])
  end
end
