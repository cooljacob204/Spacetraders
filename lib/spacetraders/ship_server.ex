defmodule Spacetraders.ShipServer do
  use GenServer
  alias Spacetraders.Ship

  def start_link(ship) do
    case GenServer.start_link(__MODULE__, ship, name: via_tuple(ship.symbol)) do
      {:ok, pid} ->
        Task.start(fn -> Spacetraders.Genservers.Agent.add_ship(ship.agent_symbol, ship.symbol) end)
        {:ok, pid}
      {:error, {:already_started, pid}} -> {:already_started, pid}
    end
  end

  def sync(symbol) do
    GenServer.call(via_tuple(symbol), :sync)
  end

  def get(symbol) do
    GenServer.call(via_tuple(symbol), :get)
  end

  def dock(symbol) do
    GenServer.call(via_tuple(symbol), :dock)
  end

  def orbit(symbol) do
    GenServer.call(via_tuple(symbol), :orbit)
  end

  def extract(symbol) do
    GenServer.call(via_tuple(symbol), :extract)
  end

  def stop_extracting(symbol) do
    GenServer.call(via_tuple(symbol), :stop_extracting)
  end

  def navigate(symbol, waypoint) do
    GenServer.call(via_tuple(symbol), {:navigate, waypoint})
  end

  def sell_cargo(symbol) do
    GenServer.call(via_tuple(symbol), :sell_cargo)
  end

  def set_transition(symbol, callback, data) do
    GenServer.call(via_tuple(symbol), {:set_transition, callback, data})
  end
  def remove_transition(symbol) do
    GenServer.call(via_tuple(symbol), :remove_transition)
  end

  defp via_tuple(symbol), do: {:via, Registry, {ShipRegistry, symbol}}

  defp children_list(agent) do
    Enum.map(Spacetraders.Ship.list_ships(agent), fn ship ->
      %{ id: via_tuple(ship.symbol),
        start: {Spacetraders.ShipServer, :start_link, [ship]}
      }
    end)
  end

  def children_list do
    List.flatten(Enum.map(Spacetraders.Agent.list_agents(), fn agent -> children_list(agent) end))
  end

  @impl true
  def init(%Ship{} = ship), do: {:ok, ship}

  @impl true
  def handle_call(:get, _from, ship),
    do: {:reply, ship, ship}

  @impl true
  def handle_call(:sync, _from, ship) do
    {resp, ship} = Spacetraders.Ships.sync(ship)
    {:reply, resp, ship}
  end
  def handle_call(:dock, _from, ship) do
    {resp, ship} = Spacetraders.Ships.dock(ship)
    {:reply, resp, ship}
  end
  def handle_call(:orbit, _from, ship) do
    {resp, ship} = Spacetraders.Ships.orbit(ship)
    {:reply, resp, ship}
  end
  def handle_call(:extract, _from, ship) do
    {resp, ship} = Spacetraders.Ships.extract(ship)
    {:reply, resp, ship}
  end
  def handle_call(:stop_extracting, _from, ship) do
    {resp, ship} = Spacetraders.Ships.stop_extracting(ship)
    {:reply, resp, ship}
  end
  def handle_call({:navigate, waypoint}, _from, ship) do
    {resp, ship} = Spacetraders.Ships.navigate(ship, waypoint)
    {:reply, resp, ship}
  end
  def handle_call(:sell_cargo, _from, ship) do
    {resp, ship} = Spacetraders.Ships.sell_cargo(ship)
    {:reply, resp, ship}
  end
  def handle_call({:set_transition, callback, data}, _from, ship) do
    {resp, ship} = Spacetraders.Ships.set_transition(ship, callback, data)
    {:reply, resp, ship}
  end
  def handle_call(:remove_transition, _from, ship) do
    {resp, ship} = Spacetraders.Ships.remove_transition(ship)
    {:reply, resp, ship}
  end

  @impl true
  def handle_info(:extract_cooldown_ended, ship) do
    {_, ship} = Spacetraders.Ships.extract_cooldown_ended(ship)
    {:noreply, ship}
  end
  def handle_info(:navigation_complete, ship) do
    {_, ship} = Spacetraders.Ships.navigation_complete(ship)
    {:noreply, ship}
  end
  def handle_info(:sell_cargo, ship) do
    {_, ship} = Spacetraders.Ships.sell_cargo(ship)
    {:noreply, ship}
  end
end
