defmodule Spacetraders.Api.Ship do
  import Spacetraders.Api

  def get_ship(agent, symbol) do
    get(agent, "/my/ships/#{symbol}")
  end

  def orbit(agent, ship) do
    post(agent, "/my/ships/#{ship.symbol}/orbit")
  end

  def dock(agent, ship) do
    post(agent, "/my/ships/#{ship.symbol}/dock")
  end
end
