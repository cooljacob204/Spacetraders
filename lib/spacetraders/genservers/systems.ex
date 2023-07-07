defmodule Spacetraders.Genservers.Systems do
  use GenServer
  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  def get(agent, system_symbol) do
    {:ok, system} = GenServer.call(__MODULE__, {:get, system_symbol, agent.symbol})

    system
  end

  # Server

  @impl true
  def init(systems) do
    {:ok, systems}
  end

  @impl true
  def handle_call({:get, system_symbol, agent_symbol}, _from, systems) do
    agent = Spacetraders.Genservers.Agent.get(agent_symbol)

    case Map.get(systems, system_symbol) do
      nil ->
        case Spacetraders.Api.System.get_system(agent, system_symbol) do
          {:ok, %{"data" => data}} ->
            system = Spacetraders.System.changeset(%Spacetraders.System{}, data) |> Ecto.Changeset.apply_changes()
            {:reply, {:ok, system}, Map.put(systems, system_symbol, system)}
          {:ok, %{"error" => error}} ->
            {:reply, {:error, error}, systems}
        end
      system ->
        {:reply, {:ok, system}, systems}
    end
  end
end
