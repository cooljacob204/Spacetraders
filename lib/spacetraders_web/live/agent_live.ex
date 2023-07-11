defmodule SpacetradersWeb.AgentLive do
  use SpacetradersWeb, :live_view

  def mount(params, _session, socket) do
    agent = Spacetraders.Genservers.Agent.get(String.upcase(params["symbol"]))
    if connected?(socket) do
      Spacetraders.Genservers.Agent.subscribe(agent)
    end

    {
      :ok,
      socket
      |> assign(:agent, agent)
      |> assign(:subscribed_ships, subscribe_to_ships(agent.ships, socket))
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
      <content class='flex flex-row flex-wrap'>
        <%= for ship <- Enum.sort(assigns.agent.ships) do %>
          <.live_component module={SpacetradersWeb.Live.ShipComponent} id={ship} ship_symbol={ship} agent={assigns.agent}/>
        <% end %>
      </content>
    """
  end

  def handle_info({:agent_updated, agent}, socket) do
    {:noreply, socket |> assign(:agent, agent) |> assign(:subscribed_ships, subscribe_to_ships(agent.ships, socket))}
  end
  def handle_info({:ship_updated, ship}, socket) do
    send_update SpacetradersWeb.Live.ShipComponent, id: ship.symbol, ship_symbol: ship.symbol, agent: socket.assigns.agent
    {:noreply, socket}
  end

  defp subscribed_ships(socket) do
    if connected?(socket) do
      if Map.has_key?(socket.assigns, :subscribed_ships) do
        socket.assigns.subscribed_ships
      else
        MapSet.new()
      end
    else
      MapSet.new()
    end
  end

  defp subscribe_to_ships(ships, socket) do
    if connected?(socket) do
      Enum.reduce(ships, subscribed_ships(socket), fn ship, subscribed_ships ->
        if MapSet.member?(subscribed_ships, ship) do
          subscribed_ships
        else
          Spacetraders.Ships.subscribe(ship)

          MapSet.put(subscribed_ships, ship)
        end
      end)
    else
      MapSet.new()
    end
  end
end
