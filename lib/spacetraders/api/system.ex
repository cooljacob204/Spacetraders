defmodule Spacetraders.Api.System do
  import Spacetraders.Api

  def get_system(agent, system_symbol) do
    get(agent, "/systems/#{system_symbol}")
  end

  def get_systems(agent, opts \\ []) do
    get(agent, "/systems", opts)
  end
end
