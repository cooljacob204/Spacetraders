defmodule SpacetradersWeb.Api.ShipsAndTheirSystemsController do
  use SpacetradersWeb, :controller
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    ships = List.flatten(Enum.map(Spacetraders.Agent.list_agents(), fn agent ->
      agent = Spacetraders.Genservers.Agent.get(agent.symbol)
      Enum.map(agent.ships, fn ship ->
        ship = Spacetraders.ShipServer.get(ship)
        system = from(s in Spacetraders.System, where: s.symbol == ^ship.nav.system_symbol, select: s) |> Spacetraders.Repo.one()

        %{ship: ship, system: system}
      end)
    end))

    json(conn, %{data: ships})
  end
end
