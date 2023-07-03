defmodule Spacetraders.Ship do
  import Ecto.Changeset
  defstruct [:agent_symbol, :symbol, :nav, :crew, :fuel, :frame, :reactor, :engine, :modules, :mounts, :registration, :cargo]

  def list_ships(agent) do
    ships = case Spacetraders.Api.Agent.get_ships(agent) do
      %{"data" => data} -> data
      %{"error" => error } -> raise "Error: #{error}"
    end

    Enum.map(ships, fn attrs ->
      changeset(%Spacetraders.Ship{agent_symbol: agent.symbol}, attrs)
      |> apply_changes()
    end)
  end

  def changeset(ship, attrs) do
    types = %{
      agent_symbol: :string,
      symbol: :string,
      nav: :any,
      crew: :any,
      fuel: :any,
      frame: :any,
      reactor: :any,
      engine: :any,
      modules: {:array, :map},
      mounts: {:array, :map},
      registration: :any,
      cargo: :any
    }

    {ship, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required([:agent_symbol, :symbol, :nav, :crew, :fuel, :frame, :reactor, :engine, :modules, :mounts, :registration, :cargo])
  end
end
