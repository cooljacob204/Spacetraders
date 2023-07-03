defmodule Spacetraders.Api.Agent do
  def my_agent(agent) do
    Spacetraders.Api.get(agent, "/my/agent")
  end

  def get_ships(agent) do
    Spacetraders.Api.get(agent, "/my/ships")
  end

  def get_ship(agent, symbol) do
    Spacetraders.Api.get(agent, "/my/ships/#{symbol}")
  end
end
