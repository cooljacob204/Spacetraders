defmodule Spacetraders.Api.Waypoints do
  import Spacetraders.Api

  def get_waypoint(agent, system_symbol, waypoint_symbol) do
    get(agent, "/systems/#{system_symbol}/waypoints/#{waypoint_symbol}")
  end

  def get_waypoints(agent, system_symbol, opts \\ []) do
    get(agent, "/systems/#{system_symbol}/waypoints", opts)
  end

  def get_jump_gate(agent, system_symbol, waypoint_symbol) do
    get(agent, "/systems/#{system_symbol}/waypoints/#{waypoint_symbol}/jump-gate")
  end
end
