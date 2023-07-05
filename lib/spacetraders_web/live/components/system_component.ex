defmodule SpacetradersWeb.Live.SystemComponent do
  use SpacetradersWeb, :live_component
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    system = Spacetraders.Genservers.Systems.get(assigns.agent, assigns.ship.nav.system_symbol)
    {:ok, socket |> assign(:ship, assigns.ship) |> assign(:system, system)}
  end

  def render(assigns) do
    ~H"""
    <div class='border-2 rounded'>
      <div class='p-2'>
        <div class='text-xl font-bold'><%= assigns.system.symbol %></div>
        <div>type: <%= assigns.system.type %></div>
        <div>x: <%= assigns.system.x %></div>
        <div>y: <%= assigns.system.y %></div>
        <div class='text-lg font-bold mt-2'>Waypoints</div>
      </div>
      <div class='border-t-2 p-2 mt-2'>
          <%= for waypoint <- assigns.system.waypoints do %>
            <div class='border-2 rounded my-1 p-1 flex flex-row justify-between'>
              <div>
                <div>symbol: <%= waypoint.symbol %></div>
                <div>type: <%= waypoint.type %></div>
                <div>x: <%= waypoint.x %></div>
                <div>y: <%= waypoint.y %></div>
              </div>
              <div>
                <.button disabled={true}>show</.button>
                <.button disabled={assigns.ship.nav.status == :DOCKED} phx-click="travel" value={waypoint.symbol} phx-target={@myself}>travel</.button>
              </div>
            </div>
          <% end %>
      </div>
    </div>
    """
  end

  def handle_event("travel", params, socket) do
    Spacetraders.ShipServer.navigate(socket.assigns.ship.symbol, params["value"])

    {:noreply, socket}
  end
end
