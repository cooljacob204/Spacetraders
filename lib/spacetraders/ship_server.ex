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
  def handle_call({:update, attrs}, _from, ship) do
    ship = update(ship, attrs)

    {:reply, ship, ship}
  end

  @impl true
  def handle_call(:sync, _from, ship) do
    {:reply, {:ok, :synced}, run_sync(ship)}
  end
  def handle_call(:dock, _from, %Ship{state: :in_orbit} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.dock(agent(ship), ship)
    attrs = Map.put(attrs, "state", "docked")

    {:reply, {:ok, :docked}, ship |> update(attrs)}
  end
  def handle_call(:dock, _from, ship), do: {:reply, {:error, "Ship not in orbit"}, ship}
  def handle_call(:orbit, _from, %Ship{state: :docked} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.orbit(agent(ship), ship)
    attrs = Map.put(attrs, "state", "in_orbit")

    {:reply, {:ok, :in_orbit}, ship |> update(attrs)}
  end
  def handle_call(:orbit, _from, ship), do: {:reply, {:error, "Ship not docked"}, ship}
  def handle_call(:extract, _from, %Ship{state: :in_orbit} = ship) do
    case Ship.Extraction.extract(ship, agent(ship)) do
      {:ok, :cooldown} -> {:reply, {:ok, :cooldown}, ship |> update(%{state: :extracting})}
      {:ok, :cargo_full} -> {:reply, {:ok, :cargo_full}, ship}
      {:ok, cargo} -> {:reply, {:ok, :extracting}, ship |> update(%{state: :extracting, cargo: cargo})}
      {:error, error} -> {:reply, error, ship}
    end
  end
  def handle_call(:extract, _from, ship), do: {:reply, {:error, "Ship not in orbit"}, ship}
  def handle_call(:stop_extracting, _from, %Ship{state: :extracting} = ship), do:
    {:reply, :ok, ship |> update(%{state: :in_orbit})}
  def handle_call(:stop_extracting, _from, ship), do: {:reply, {:error, "Ship not extracting"}, ship}
  def handle_call(:idle, _from, %Ship{} = ship) do
    ship = update(ship, %{state: :idle})

    {:reply, :ok, ship}
  end
  def handle_call({:navigate, waypoint}, _from, %Ship{state: :in_orbit} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.navigate(agent(ship), ship, waypoint)
    attrs = Map.put(attrs, "state", "in_transit")

    ship = update(ship, attrs)

    {:ok, arrival_time, 0} = DateTime.from_iso8601(attrs["nav"]["route"]["arrival"])
    Process.send_after(self(), :navigation_complete, (DateTime.to_unix(arrival_time) - System.system_time(:second)) * 1000)

    {:reply, ship, ship}
  end
  def handle_call({:navigate, _waypoint}, _from, ship), do: {:reply, {:error, "Ship not in orbit"}, ship}
  def handle_call(:sell_cargo, _from, %Ship{state: :docked, cargo: %{inventory: []}} = ship), do: {:reply, {:error, "No cargo to sell"}, ship}
  def handle_call(:sell_cargo, _from, %Ship{state: :docked} = ship) do
    item_to_sell = hd ship.cargo.inventory

    case Ship.Cargo.sell_item(ship, item_to_sell) do
      {:ok, cargo, agent} ->
        Spacetraders.Genservers.Agent.update(agent["symbol"], agent)
        send(self(), :sell_cargo)
        {:reply, {:ok, :selling}, ship |> update(%{state: :selling_cargo, cargo: cargo})}
      {:error, error} -> {:reply, error, ship}
    end
  end
  def handle_call(:sell_cargo, _from, ship), do: {:reply, {:error, "Ship not docked"}, ship}
  def handle_call({:set_transition, callback, data}, _from, ship) do
    {:reply, {:ok, :transition_set}, ship |> update(%{transition: %{callback: callback, data: data}})}
  end

  @impl true
  def handle_info(:extract_cooldown_ended, %Ship{state: :extracting} = ship) do
    case Ship.Extraction.extract(ship, agent(ship)) do
      {:ok, :cooldown} -> {:noreply, ship}
      {:ok, :cargo_full} -> {:noreply, ship |> update(%{state: :in_orbit})}
      {:ok, cargo} -> {:noreply, ship |> update(%{state: :extracting, cargo: cargo})}
      {:error, _error} -> {:noreply, ship |> update(%{state: :in_orbit})}
    end
  end
  def handle_info(:extract_cooldown_ended, ship), do: {:noreply, ship}
  def handle_info(:navigation_complete, %Ship{state: :in_transit} = ship) do
    update(ship, %{state: :in_orbit, nav: %{status: :IN_ORBIT}})

    {:noreply, ship}
  end
  def handle_info(:navigation_complete, ship), do: {:noreply, ship}
  def handle_info(:sell_cargo, %Ship{state: :selling_cargo, cargo: %{inventory: []}} = ship) do
    {:noreply, ship |> update(%{state: :docked})}
  end
  def handle_info(:sell_cargo, %Ship{state: :selling_cargo} = ship) do
    case Ship.Cargo.sell_item(ship, hd(ship.cargo.inventory)) do
      {:ok, cargo, agent} ->
        Spacetraders.Genservers.Agent.update(agent["symbol"], agent)
        send(self(), :sell_cargo)
        {:noreply, ship |> update(%{state: :selling_cargo, cargo: cargo})}
      {:error, _error} -> {:noreply, ship |> update(%{state: :docked})}
    end
  end
  def handle_info(:sell_cargo, ship), do: {:noreply, ship}

  defp run_sync(ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.get_ship(agent(ship), ship.symbol)

    ship |> update(attrs)
  end

  defp agent(%Ship{agent_symbol: agent_symbol}), do: Spacetraders.Genservers.Agent.get(agent_symbol)

  defp update(ship, attrs) do
    updated_ship = ship
      |> Ship.changeset(attrs)
      |> Ecto.Changeset.apply_changes()

    broadcast({:ok, updated_ship}, :ship_updated)

    if updated_ship.state != ship.state do
      transition(ship, updated_ship)
    end

    updated_ship
  end
  defp transition(old_ship, ship) do
    if ship.transition.callback do
      ship.transition.callback.(ship, ship.state, old_ship.state, ship.transition.data)
    end
  end

  def subscribe(%Spacetraders.Ship{} = ship) do
    Phoenix.PubSub.subscribe(Spacetraders.PubSub, "ship-#{ship.symbol}")
  end

  # defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, %Spacetraders.Ship{} = ship}, event) do
    Phoenix.PubSub.broadcast(Spacetraders.PubSub, "ship-#{ship.symbol}", {event, ship})

    {:ok, ship}
  end
end
