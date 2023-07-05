defmodule Spacetraders.Ship.SellCargo do
  import Spacetraders.Api

  def sell_cargo(agent, ship, symbol, units) do
    post(agent, "/my/ships/#{ship.symbol}/sell", Jason.encode!(%{symbol: symbol, units: units}))
  end
end
