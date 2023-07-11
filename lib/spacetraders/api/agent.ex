defmodule Spacetraders.Api.Agent do
  import Spacetraders.Api
  def my_agent(agent) do
    get(agent, "/my/agent")
  end

  def get_ships(agent, opts \\ []) do
    get(agent, "/my/ships", opts)
  end
end
