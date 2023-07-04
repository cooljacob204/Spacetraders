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

  defp process_id(symbol),
    do: {:via, Registry, {ShipRegistry, symbol}}

  # Server
  @impl true
  def init(ship) do
    {:ok, ship}
  end

  @impl true
  def handle_call(:get, _from, ship) do
    {:reply, ship, ship}
  end

  @impl true
  def handle_cast({:update, attrs}, ship) do
    ship = ship
      |> Spacetraders.Ship.changeset(attrs)
      |> Ecto.Changeset.apply_changes()

    broadcast({:ok, ship}, :ship_updated)

    {:noreply, ship}
  end

  @impl true
  def handle_cast(:sync, %Spacetraders.Ship{} = ship) do
    agent = Spacetraders.Genservers.Agent.get(ship.agent_symbol)

    %{"data" => attrs} = Spacetraders.Api.Ship.get_ship(agent, ship.symbol)

    update(ship.symbol, attrs)

    {:noreply, ship}
  end
  def handle_cast(:dock, ship) do
    agent = Spacetraders.Genservers.Agent.get(ship.agent_symbol)

    %{"data" => attrs} = Spacetraders.Api.Ship.dock(agent, ship)

    update(ship.symbol, attrs)

    {:noreply, ship}
  end
  def handle_cast(:orbit, ship) do
    agent = Spacetraders.Genservers.Agent.get(ship.agent_symbol)

    %{"data" => attrs} = Spacetraders.Api.Ship.orbit(agent, ship)

    update(ship.symbol, attrs)

    {:noreply, ship}
  end

  def subscribe(%Spacetraders.Ship{} = ship) do
    Phoenix.PubSub.subscribe(Spacetraders.PubSub, "ship-#{ship.symbol}")
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, %Spacetraders.Ship{} = ship}, event) do
    Phoenix.PubSub.broadcast(Spacetraders.PubSub, "ship-#{ship.symbol}", {event, ship})

    {:ok, ship}
  end
end
