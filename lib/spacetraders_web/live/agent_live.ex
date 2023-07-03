defmodule SpacetradersWeb.AgentLive do
  use SpacetradersWeb, :live_view

  def mount(params, _session, socket) do
    agent = Spacetraders.Genservers.Agent.get(params["symbol"])
    Spacetraders.Genservers.Agent.subscribe(agent)

    {
      :ok,
      socket
      |> assign(:agent, agent)
    }
  end

  def render(assigns) do
    ~H"""
      <div class='flex flex-row p-4'>
        <div>
          <p><%= assigns.agent.symbol %></p>
          <p><%= assigns.agent.headquarters %></p>
          <p><%= assigns.agent.starting_faction %></p>
          <p><%= assigns.agent.credits %></p>
        </div>
      </div>
    """
  end

  def handle_event("update", %{"symbol" => symbol}, socket) do
    {:noreply, assign(socket, :agent, Spacetraders.Genservers.Agent.get(symbol))}
  end

  def handle_info({:agent_updated, agent}, socket) do
    {:noreply, socket |> assign(:agent, agent)}
  end
end
