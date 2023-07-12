defmodule Spacetraders.Waypoint do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias Spacetraders.Repo

  alias Spacetraders.Waypoint.{Chart, Traits}

  @derive Jason.Encoder
  schema "waypoints" do
    field :symbol, :string
    field :type, Ecto.Enum, values: [:PLANET, :GAS_GIANT, :MOON, :ORBITAL_STATION, :JUMP_GATE, :ASTEROID_FIELD, :NEBULA, :DEBRIS_FIELD, :GRAVITY_WELL]
    field :position, Geo.PostGIS.Geometry
    embeds_one :chart, Chart, on_replace: :delete
    embeds_many :traits, Traits, on_replace: :delete
    field :orbitals, {:array, :string}
    embeds_one :faction, Spacetraders.System.Faction, on_replace: :delete

    belongs_to :system, Spacetraders.System

    timestamps()
  end

  @doc false
  def changeset(waypoint, attrs) do
    waypoint
    |> cast(attrs, [:symbol, :type, :position])
    |> validate_required([:symbol, :type, :position])
    |> cast_embed(:chart, with: &Chart.changeset/2)
    |> cast_embed(:traits, with: &Traits.changeset/2)
    |> cast_embed(:faction, with: &Spacetraders.System.Faction.changeset/2)
  end

  def load_waypoints(agent) do
    systems = from(
      s in Spacetraders.System,
      select: s
    ) |> Repo.all()

    Enum.each(systems, fn system ->
      load_waypoints(agent, system)
    end)
  end
  def load_waypoints(agent, system),  do: load_waypoints(agent, system, 1)
  def load_waypoints(agent, system, page) do
    limit = 20
    {:ok, %{"data" => waypoints, "meta" => meta}} = Spacetraders.Api.Waypoints.get_waypoints(agent, system.symbol, params: %{limit: limit, page: page})
    prepped_waypoints = Enum.map(waypoints, fn waypoint -> prep_waypoint(waypoint, system) end)

    Repo.insert_all(Spacetraders.Waypoint, prepped_waypoints, conflict_target: :symbol, on_conflict: {:replace, [:system_id, :symbol, :type, :position, :chart, :traits, :orbitals, :faction, :updated_at]})

    current_page = meta["page"]
    total_count = meta["total"]

    if current_page * limit < total_count do
      load_waypoints(agent, system, current_page + 1)
    end
  end
  defp prep_waypoint(waypoint, system) do
    changeset(%Spacetraders.Waypoint{}, %{
      symbol: waypoint["symbol"],
      type: waypoint["type"],
      position: %Geo.Point{coordinates: {waypoint["x"], waypoint["y"]}, srid: 3857},
      traits: waypoint["traits"],
      orbitals: waypoint["orbitals"],
      chart: waypoint["chart"],
      faction: waypoint["faction"]
    }) |> Ecto.Changeset.apply_changes()
       |> Map.take([:symbol, :type, :position, :chart, :traits, :orbitals, :faction])
       |> Map.put(:system_id, system.id)
  end

  def get_waypoint(waypoint_symbol) do
    from(
      w in Spacetraders.Waypoint,
      where: w.symbol == ^waypoint_symbol,
      limit: 1,
      select: w
    ) |> Repo.one!()
  end

  def get_systems_waypoints_with_distance(system, waypoint) do
    query = from w in Spacetraders.Waypoint,
      where: w.system_id == ^system.id,
      order_by: fragment("ST_Distance(?, ?)", w.position, ^waypoint.position),
      select: {w, fragment("ST_Distance(?, ?)", w.position, ^waypoint.position)}

    Repo.all(query)
  end
  def get_systems_waypoints_with_distance(system) do
    query = from w in Spacetraders.Waypoint,
      where: w.system_id == ^system.id,
      order_by: fragment("ST_Distance(?, ?)", w.position, ^%Geo.Point{coordinates: {0, 0}, srid: 3857}),
      select: {w, fragment("ST_Distance(?, ?)", w.position, ^%Geo.Point{coordinates: {0, 0}, srid: 3857})}

    Repo.all(query)
  end

  def get_latest_waypoint(agent, system_symbol, waypoint_symbol) do
    waypoint = from(
      w in Spacetraders.Waypoint,
      where: w.symbol == ^waypoint_symbol,
      limit: 1,
      select: w
    ) |> Repo.one()

    case Spacetraders.Api.Waypoints.get_waypoint(agent, system_symbol, waypoint_symbol) do
      {:ok, %{"data" => %{"orbitals" => orbitals, "traits" => traits} = data}} ->
        {:ok,
         changeset(waypoint, %{orbitals: orbitals, traits: traits, chart: data["chart"], faction: data["faction"]})
         |> Repo.insert!(on_conflict: {:replace, [:orbitals, :traits, :chart, :faction]}, conflict_target: :symbol)}
      {:error, %{"errors" => errors}} ->
        IO.inspect(errors)
        {:error, waypoint}
    end
  end
end
