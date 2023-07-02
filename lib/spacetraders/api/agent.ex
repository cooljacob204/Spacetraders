defmodule Spacetraders.Api.Agent do
  def my_agent(agent) do
    Spacetraders.Api.get(agent, "/my/agent")
  end
end
