defmodule Spacetraders.Api.Waypoints do
  import Spacetraders.Api

  def get_jump_gate(agent, system_symbol, waypoint_symbol) do
    get(agent, "/systems/#{system_symbol}/waypoints/#{waypoint_symbol}/jump-gate")
  end
end