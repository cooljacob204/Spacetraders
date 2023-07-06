defmodule Spacetraders.Api.Ship do
  import Spacetraders.Api

  def get_ship(agent, symbol) do
    get(agent, "/my/ships/#{symbol}")
  end

  def orbit(agent, ship) do
    post(agent, "/my/ships/#{ship.symbol}/orbit", "")
  end

  def dock(agent, ship) do
    post(agent, "/my/ships/#{ship.symbol}/dock", "")
  end

  def navigate(agent, ship, waypoint) do
    post(agent, "/my/ships/#{ship.symbol}/navigate", Jason.encode!(%{waypointSymbol: waypoint}))
  end

  def extract(agent, ship) do
    post(agent, "/my/ships/#{ship.symbol}/extract", "")
  end

  def sell_item(agent, ship, symbol, units) do
    post(agent, "/my/ships/#{ship.symbol}/sell", Jason.encode!(%{symbol: symbol, units: units}))
  end
end
