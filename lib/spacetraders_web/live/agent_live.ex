defmodule SpacetradersWeb.AgentLive do
  use SpacetradersWeb, :live_view

  def mount(params, _session, socket) do
    agent = Spacetraders.Genservers.Agent.get(String.upcase(params["symbol"]))
    Spacetraders.Genservers.Agent.subscribe(agent)

    {
      :ok,
      socket
      |> assign(:agent, agent)
    }
  end

  def render(assigns) do
    ~H"""
      <header class='flex flex-row p-1'>
        <div class = 'border-2 rounded p-2'>
          <p><%= assigns.agent.symbol %></p>
          <p><%= assigns.agent.headquarters %></p>
          <p><%= assigns.agent.starting_faction %></p>
          <p><%= assigns.agent.credits %></p>
        </div>
      </header>
      <content class='flex flex-row'>
        <%= for ship <- assigns.agent.ships do %>
            <.live_component module={SpacetradersWeb.Components.ShipLive} id={ship} ship_symbol={ship} agent={assigns.agent}/>
        <% end %>
      </content>
    """
  end

  def handle_info({:agent_updated, agent}, socket) do
    {:noreply, socket |> assign(:agent, agent)}
  end
  def handle_info({:ship_updated, ship}, socket) do
    send_update SpacetradersWeb.Components.ShipLive, id: ship.symbol, ship_symbol: ship.symbol
    {:noreply, socket}
  end
end
