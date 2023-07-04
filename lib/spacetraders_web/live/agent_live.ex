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
      <header class='flex flex-row p-2'>
        <div class = 'border-2 rounded p-2'>
          <p><%= assigns.agent.symbol %></p>
          <p><%= assigns.agent.headquarters %></p>
          <p><%= assigns.agent.starting_faction %></p>
          <p><%= assigns.agent.credits %></p>
        </div>
      </header>
      <content>
        <%= for ship <- assigns.agent.ships do %>
            <%= live_render(@socket, SpacetradersWeb.ShipLive, id: ship, session: %{"symbol" => ship}) %>
        <% end %>
      </content>
    """
  end

  def handle_info({:agent_updated, agent}, socket) do
    {:noreply, socket |> assign(:agent, agent)}
  end
end
