defmodule Spacetraders.Genservers.Agent do
  use GenServer

  # Client

  def children_list do
    Enum.map(Spacetraders.Agent.list_agents(), fn agent ->
      %{ id: String.to_atom("spacetrader_agent_#{agent.symbol}"),
        start: {Spacetraders.Genservers.Agent, :start_link, [agent]}
      }
    end)
  end

  def start_link(agent) do
    GenServer.start_link(__MODULE__, agent, name: String.to_atom("spacetrader_agent_#{agent.symbol}"))
  end

  def get(symbol) do
    GenServer.call(String.to_existing_atom("spacetrader_agent_#{symbol}"), :get)
  end

  def update(symbol, attrs) do
    GenServer.cast(String.to_existing_atom("spacetrader_agent_#{symbol}"), {:update, attrs})
  end

  def sync(symbol) do
    GenServer.cast(String.to_existing_atom("spacetrader_agent_#{symbol}"), :sync)
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

    {:noreply, agent}
  end

  @impl true
  def handle_cast(:sync, agent) do
    attrs = case Spacetraders.Api.Agent.my_agent(agent) do
      %{"data" => data} ->
        %{
          account_id: data["accountId"],
          credits: data["credits"],
          starting_faction: data["startingFaction"],
          headquarters: data["headquarters"]
        }
      %{"error" => error } -> raise "Error: #{error}"
    end

    agent = agent
      |> Spacetraders.Agent.changeset(attrs)
      |> Ecto.Changeset.apply_changes()

      {:noreply, agent}
  end
end
