defmodule Spacetraders.Ship.Routines.ExtractAndSell do
  alias Spacetraders.Ship

  def description, do: "Extracting and selling within the same system"
  def start_routine(symbol) do
    Spacetraders.ShipServer.set_transition(symbol, &transition/4, nil)
    ship = Spacetraders.ShipServer.get(symbol)

    start_routine(symbol, ship)
  end
  defp start_routine(symbol, %Ship{state: :in_orbit}) do
    Spacetraders.ShipServer.extract(symbol)

    :ok
  end
  defp start_routine(symbol, %Ship{state: :docked}) do
    Spacetraders.ShipServer.sell_cargo(symbol)

    :ok
  end
  defp start_routine(_symbol, %Ship{state: :extracting}) do
    :ok
  end
  defp start_routine(_symbol, %Ship{state: :selling_cargo}) do
    :ok
  end

  # Server Callbacks
  def transition(ship, :in_orbit, :extracting, _) do
    Spacetraders.Ships.dock(ship)
  end
  def transition(ship, :docked, :in_orbit, _) do
    Spacetraders.Ships.sell_cargo(ship)
  end
  def transition(ship, :selling_cargo, :docked, _) do
    {:ok, ship}
  end
  def transition(ship, :docked, :selling_cargo, _) do
    Spacetraders.Ships.orbit(ship)
  end
  def transition(ship, :in_orbit, :docked, _) do
    Spacetraders.Ships.extract(ship)
  end
  def transition(ship, :extracting, :in_orbit, _) do
    {:ok, ship}
  end

  def transition(ship, state, old_state, _) do
    IO.puts "Ship hit an unexpected state"
    IO.puts "State: #{state}"
    IO.puts "Old State: #{inspect old_state}"
    IO.puts "Ship: #{inspect ship}"
    Spacetraders.ShipServer.set_transition(ship.symbol, nil, nil)
    {:ok, ship}
  end
end
