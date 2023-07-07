defmodule Spacetraders.Ship.Routines.ExtractAndSell do
  alias Spacetraders.Ship

  def description, do: "Extracting and selling within the same system"
  def start_routine(symbol) do
    Spacetraders.ShipServer.set_transition(symbol, &transition/4, nil)
    ship = Spacetraders.ShipServer.get(symbol)

    start_routine(symbol, ship)
  end
  defp start_routine(symbol, %Ship{state: :in_orbit}) do
    case Spacetraders.ShipServer.extract(symbol) do
      :cargo_full -> Spacetraders.ShipServer.dock(symbol)
      :ok -> {:ok, :extracting}
      error -> {:error, error}
    end
  end
  defp start_routine(symbol, %Ship{state: :docked}) do
    case Spacetraders.ShipServer.sell_cargo(symbol) do
      {:error, "cargo empty"} -> Spacetraders.ShipServer.orbit(symbol)
      :ok -> {:ok, :selling_cargo}
      error -> {:error, error}
    end
  end
  defp start_routine(_symbol, %Ship{state: :extracting}) do
    :ok
  end
  defp start_routine(_symbol, %Ship{state: :selling_cargo}) do
    :ok
  end
  def transition(ship, :in_orbit, :extracting, _) do
    Task.start fn ->
      case Spacetraders.ShipServer.dock(ship.symbol) do
        :ok -> {:ok, :docked}
        error -> {:error, error}
      end
    end
  end
  def transition(ship, :docked, :in_orbit, _) do
    Task.start fn ->
      case Spacetraders.ShipServer.sell_cargo(ship.symbol) do
        :ok -> {:ok, :selling_cargo}
        error -> {:error, error}
      end
    end
  end
  def transition(_ship, :selling_cargo, :docked, _) do
    :noop
  end
  def transition(ship, :docked, :selling_cargo, _) do
    Task.start fn ->
      case Spacetraders.ShipServer.orbit(ship.symbol) do
        :ok -> {:ok, :in_orbit}
        error -> {:error, error}
      end
    end
  end
  def transition(ship, :in_orbit, :docked, _) do
    Task.start fn ->
      case Spacetraders.ShipServer.extract(ship.symbol) do
        :ok -> {:ok, :extracting}
        error -> {:error, error}
      end
    end
  end
  def transition(_ship, :extracting, :in_orbit, _) do
    :noop
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
