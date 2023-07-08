defmodule Spacetraders.Waypoint do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias Spacetraders.Repo

  schema "waypoints" do
    field :symbol, :string
    field :type, Ecto.Enum, values: [:PLANET, :GAS_GIANT, :MOON, :ORBITAL_STATION, :JUMP_GATE, :ASTEROID_FIELD, :NEBULA, :DEBRIS_FIELD, :GRAVITY_WELL]
    field :position, Geo.PostGIS.Geometry
    belongs_to :system, Spacetraders.System

    timestamps()
  end

  @doc false
  def changeset(waypoint, attrs) do
    waypoint
    |> cast(attrs, [:symbol, :type, :position])
    |> validate_required([:symbol, :type, :position])
  end

  def get_systems_waypoints_with_distance(system, waypoint) do
    query = from w in Spacetraders.Waypoint,
      where: w.system_id == ^system.id,
      order_by: fragment("ST_Distance(?, ?)", w.position, ^waypoint.position),
      select: {w, fragment("ST_Distance(?, ?)", w.position, ^waypoint.position)}

    Repo.all(query)
  end
end
# Spacetraders.Waypoint.get_with_distance(%{id: 12111}, %{position: %Geo.Point{coordinates: {32, 27}, srid: 3857}})
