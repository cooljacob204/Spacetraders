defmodule Spacetraders.Ship.Navigation.Route.Waypoint do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder
  embedded_schema do
    field :symbol, :string
    field :type, Ecto.Enum, values: [:PLANET, :GAS_GIANT, :MOON, :ORBITAL_STATION, :JUMP_GATE, :ASTEROID_FIELD, :NEBULA, :DEBRIS_FIELD, :GRAVITY_WELL]
    field :system_symbol, :string
    field :x, :integer
    field :y, :integer
  end

  def changeset(waypoint, attrs) do
    waypoint
    |> cast(attrs, [:symbol, :type, :system_symbol, :x, :y])
    |> validate_required([:symbol, :type, :system_symbol, :x, :y])
  end
end
