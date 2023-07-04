defmodule Spacetraders.Genservers.Ship do
  use GenServer

  # Client
  def children_list(agent) do
    Enum.map(Spacetraders.Ship.list_ships(agent), fn ship ->
      %{ id: process_id(ship.symbol),
        start: {Spacetraders.Genservers.Ship, :start_link, [ship]}
      }
    end)
  end

  def children_list do
    List.flatten(Enum.map(Spacetraders.Agent.list_agents(), fn agent -> children_list(agent) end))
  end

  def start_link(ship) do
    case GenServer.start_link(__MODULE__, ship, name: process_id(ship.symbol)) do
      {:ok, pid} ->
        Task.start(fn -> Spacetraders.Genservers.Agent.add_ship(ship.agent_symbol, ship.symbol) end)
        {:ok, pid}
      {:error, {:already_started, pid}} -> {:already_started, pid}
    end
  end

  def get(symbol) do
    GenServer.call(process_id(symbol), :get)
  end

  def update(symbol, attrs) do
    GenServer.cast(process_id(symbol), {:update, attrs})
  end

  def sync(symbol) do
    GenServer.cast(process_id(symbol), :sync)
  end

  def dock(symbol) do
    GenServer.cast(process_id(symbol), :dock)
  end

  def orbit(symbol) do
    GenServer.cast(process_id(symbol), :orbit)
  end

  def navigate(symbol, waypoint) do
    GenServer.cast(process_id(symbol), {:navigate, waypoint})
  end

  defp process_id(symbol),
    do: {:via, Registry, {ShipRegistry, symbol}}

  # Server
  @impl true
  def init(%Spacetraders.Ship{} = ship) do
    {:ok, ship}
  end

  @impl true
  def handle_call(:get, _from, %Spacetraders.Ship{} = ship) do
    {:reply, ship, ship}
  end

  @impl true
  def handle_cast({:update, attrs}, %Spacetraders.Ship{} = ship) do
    ship = ship
      |> Spacetraders.Ship.changeset(attrs)
      |> Ecto.Changeset.apply_changes()

    broadcast({:ok, ship}, :ship_updated)

    {:noreply, ship}
  end

  @impl true
  def handle_cast(:sync, %Spacetraders.Ship{} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.get_ship(agent(ship), ship.symbol)

    update(ship.symbol, attrs)

    {:noreply, ship}
  end
  def handle_cast(:dock, %Spacetraders.Ship{} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.dock(agent(ship), ship)

    update(ship.symbol, attrs)

    {:noreply, ship}
  end
  def handle_cast(:orbit, %Spacetraders.Ship{} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.orbit(agent(ship), ship)

    update(ship.symbol, attrs)

    {:noreply, ship}
  end
  def handle_cast({:navigate, waypoint}, %Spacetraders.Ship{} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.navigate(agent(ship), ship, waypoint)

    update(ship.symbol, attrs)

    {:ok, arrival_time, 0} = DateTime.from_iso8601(attrs["nav"]["route"]["arrival"])
    Process.send_after(self(), :sync, (DateTime.to_unix(arrival_time) - System.system_time(:second) + 1) * 1000)

    {:noreply, ship}
  end

  @impl true
  def handle_info(:sync, %Spacetraders.Ship{} = ship) do
    sync(ship.symbol)

    {:noreply, ship}
  end

  defp agent(ship),
    do: Spacetraders.Genservers.Agent.get(ship.agent_symbol)

  def subscribe(%Spacetraders.Ship{} = ship) do
    Phoenix.PubSub.subscribe(Spacetraders.PubSub, "ship-#{ship.symbol}")
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, %Spacetraders.Ship{} = ship}, event) do
    Phoenix.PubSub.broadcast(Spacetraders.PubSub, "ship-#{ship.symbol}", {event, ship})

    {:ok, ship}
  end
end
