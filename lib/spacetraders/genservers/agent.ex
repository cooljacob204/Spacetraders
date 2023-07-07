defmodule Spacetraders.Genservers.Agent do
  use GenServer

  # Client

  def children_list do
    Enum.map(Spacetraders.Agent.list_agents(), fn agent ->
      %{ id: via_tuple(agent.symbol),
        start: {Spacetraders.Genservers.Agent, :start_link, [agent]}
      }
    end)
  end

  def start_link(agent) do
    case GenServer.start_link(__MODULE__, agent, name: via_tuple(agent.symbol)) do
      {:ok, pid} ->
        Task.start(fn -> Spacetraders.Genservers.Agent.sync(agent.symbol) end)
        {:ok, pid}
      {:error, {:already_started, pid}} -> {:already_started, pid}
    end
  end

  defp via_tuple(symbol),
    do: {:via, Registry, {AgentRegistry, symbol}}

  def get(symbol) do
    GenServer.call(via_tuple(symbol), :get)
  end

  def update(symbol, attrs) do
    GenServer.cast(via_tuple(symbol), {:update, attrs})
  end

  def sync(symbol) do
    GenServer.cast(via_tuple(symbol), :sync)
  end

  def add_ship(symbol, ship_symbol) do
    GenServer.cast(via_tuple(symbol), {:add_ship, ship_symbol})
  end

  # Server
  @impl true
  def init(agent) do
    {:ok, agent}
  end

  @impl true
  def handle_call(:get, _from, agent) do
    {:reply, agent, agent}
  end

  @impl true
  def handle_cast({:update, attrs}, agent) do
    agent = agent
      |> Spacetraders.Agent.changeset(attrs)
      |> Ecto.Changeset.apply_changes()

    broadcast({:ok, agent}, :agent_updated)

    {:noreply, agent}
  end
  def handle_cast({:add_ship, ship_symbol}, agent) do
    agent = agent
      |> Spacetraders.Agent.changeset(%{ships: Enum.uniq([ship_symbol | agent.ships])})
      |> Ecto.Changeset.apply_changes()

    broadcast({:ok, agent}, :agent_updated)

    {:noreply, agent}
  end
  def handle_cast(:sync, agent) do
    attrs = case Spacetraders.Api.Agent.my_agent(agent) do
      {:ok, %{"data" => data}} -> data
      {:ok, %{"error" => error }} -> raise "Error: #{error}"
    end

    update(agent.symbol, attrs)

    {:noreply, agent}
  end

  def subscribe(%Spacetraders.Agent{} = agent) do
    Phoenix.PubSub.subscribe(Spacetraders.PubSub, "agent-#{agent.symbol}")
  end

  # defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, %Spacetraders.Agent{} = agent}, event) do
    Phoenix.PubSub.broadcast(Spacetraders.PubSub, "agent-#{agent.symbol}", {event, agent})

    {:ok, agent}
  end
end
