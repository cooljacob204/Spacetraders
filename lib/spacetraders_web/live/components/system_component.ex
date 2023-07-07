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
    <div>
      <div class='p-2'>
        <div class='text-xl font-bold'><%= assigns.system.symbol %></div>
        <div><span class='font-bold'>Type:</span> <%= assigns.system.type %></div>
        <div><span class='font-bold'>X:</span><%= assigns.system.x %></div>
        <div><span class='font-bold'>Y:</span><%= assigns.system.y %></div>
      </div>
      <div class='text-lg font-bold mt-2 pt-2'>Waypoints</div>
      <div class=''>
          <%= for waypoint <- assigns.system.waypoints do %>
            <div class='border-2 rounded my-1 p-1 flex flex-row justify-between'>
              <div>
                <div><span class='font-bold'>Symbol:</span> <%= waypoint.symbol %></div>
                <div><span class='font-bold'>Type:</span> <%= waypoint.type %></div>
                <div><span class='font-bold'>X:</span> <%= waypoint.x %></div>
                <div><span class='font-bold'>Y:</span> <%= waypoint.y %></div>
              </div>
              <div>
                <.button disabled={true}>show</.button>
                <.button disabled={assigns.ship.state != :in_orbit} phx-click="travel" value={waypoint.symbol} phx-target={@myself}>travel</.button>
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
