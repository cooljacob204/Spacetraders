defmodule Spacetraders.System do
  use Ecto.Schema
  import Ecto.Changeset
  alias Spacetraders.{Repo, Waypoint}
  import Ecto.Query, only: [from: 2]

  schema "systems" do
    field :symbol, :string
    field :sector_symbol, :string
    field :type, Ecto.Enum, values: [:NEUTRON_STAR, :RED_STAR, :ORANGE_STAR, :BLUE_STAR, :YOUNG_STAR, :WHITE_DWARF, :BLACK_HOLE, :HYPERGIANT, :NEBULA, :UNSTABLE]
    field :position, Geo.PostGIS.Geometry
    has_many :waypoints, Waypoint
    embeds_many :factions, Spacetraders.System.Faction

    timestamps()
  end

  def changeset(system, attrs) do
    system
    |> cast(attrs, [:symbol, :sector_symbol, :type, :position])
    |> validate_required([:symbol, :sector_symbol, :type, :position])
    |> cast_embed(:factions, with: &Spacetraders.System.Faction.changeset/2)
    |> cast_assoc(:waypoints, with: &Waypoint.changeset/2)
  end

  def load_systems(agent), do: load_systems(agent, 1)
  def load_systems(agent, page) do
    limit = 20
    {:ok, %{"data" => systems, "meta" => meta}} = Spacetraders.Api.System.get_systems(agent, params: %{limit: limit, page: page})
    prepped_systems = Enum.map(systems, fn system -> prep_system_map(system) end)

    Repo.insert_all(Spacetraders.System, prepped_systems, conflict_target: :symbol, on_conflict: {:replace, [:symbol, :sector_symbol, :type, :position, :factions, :updated_at]})

    load_waypoints(systems)

    current_page = meta["page"]
    total_count = meta["total"]

    if current_page * limit < total_count do
      Process.sleep(500)
      load_systems(agent, current_page + 1)
    end
  end
  defp load_waypoints(systems) do
    symbols = Enum.map(systems, fn data -> data["symbol"] end)

    systems_in_db = Repo.all(
      from u in Spacetraders.System,
      where: u.symbol in ^symbols,
      select: [:id, :symbol]
    ) |> Enum.reduce(%{}, fn system, acc -> Map.put(acc, system.symbol, system.id) end)

    prepped_waypoints = List.flatten(Enum.map(systems, fn system ->
      system["waypoints"]
      |> Enum.map(fn waypoint -> prep_waypoint(waypoint, Map.get(systems_in_db, system["symbol"])) end)
    end))

    Repo.insert_all(Spacetraders.Waypoint, prepped_waypoints, conflict_target: :symbol, on_conflict: {:replace, [:symbol, :type, :position, :system_id, :updated_at]})
  end
  defp prep_system_map(data) do
    Spacetraders.System.changeset(%Spacetraders.System{}, %{
      symbol: data["symbol"],
      sector_symbol: data["sector_symbol"],
      type: data["type"],
      position: %Geo.Point{coordinates: {data["x"], data["y"]}, srid: 3857},
      factions: data["factions"]
    }) |> Ecto.Changeset.apply_changes()
       |> Map.take([:symbol, :sector_symbol, :type, :position, :factions])
  end
  defp prep_waypoint(waypoint, system_id) do
    Spacetraders.Waypoint.changeset(%Spacetraders.Waypoint{},
      %{
        symbol: waypoint["symbol"],
        type: waypoint["type"],
        position: %Geo.Point{coordinates: {waypoint["x"], waypoint["y"]}, srid: 3857}
      }
    ) |> Ecto.Changeset.apply_changes()
      |> Map.take([:symbol, :type, :position])
      |> Map.put(:system_id, system_id)
  end
end
