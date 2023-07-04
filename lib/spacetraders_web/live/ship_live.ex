defmodule SpacetradersWeb.ShipLive do
  use SpacetradersWeb, :live_view

  def mount(_params, session, socket) do
    ship = Spacetraders.Genservers.Ship.get(session["symbol"])
    Spacetraders.Genservers.Ship.subscribe(ship)

    {
      :ok,
      socket
      |> assign(:ship, ship)
    }
  end

  def render(assigns) do
    ~H"""
    <div class='border-2 rounded p-2 m-1'>
      <div class='text-xl font-bold p-2'><%= assigns.ship.symbol %></div>
      <div class='flex flex-row gap-1'>
        <div class='border-2 rounded p-2'>
          <div class='text-lg font-bold'>Registration</div>
          <div>Name: <%= assigns.ship.registration.name %></div>
          <div>Faction: <%= assigns.ship.registration.faction_symbol %></div>
          <div>Role: <%= assigns.ship.registration.role %></div>
        </div>
        <div class='border-2 rounded p-2'>
          <div class='p-2 flex flex-row gap-1'>
            <div>
              <div class='text-lg font-bold'>Navigation</div>
              <div>System: <%= assigns.ship.nav.system_symbol %></div>
              <div>Waypoint: <%= assigns.ship.nav.waypoint_symbol %></div>
              <div>Status: <%= assigns.ship.nav.status %></div>
              <div>Flight Mode: <%= assigns.ship.nav.flight_mode %></div>
            </div>
            <div>
              <%= if assigns.ship.nav.status == :DOCKED do %>
                <button class='rounded-full bg-cyan-500 text-white px-4 py-2' phx-click="orbit">Orbit</button>
              <% else %>
                <button class='rounded-full bg-cyan-500 text-white px-4 py-2' phx-click="dock">Dock</button>
              <% end %>
            </div>
          </div>
          <div class='border-2 rounded p-2'>
            <div class='font-bold'>Route</div>
            <div class='flex flex-row gap-1'>
              <div class='border-2 rounded p-2 flexbox'>
                Departure:
                <div>System: <%= assigns.ship.nav.route.departure.system_symbol %></div>
                <div>Waypoint: <%= assigns.ship.nav.route.departure.symbol %></div>
                <div>Type: <%= assigns.ship.nav.route.departure.type %></div>
                <div>Location: [<%= assigns.ship.nav.route.departure.x %>, <%= assigns.ship.nav.route.departure.y %>]</div>
              </div>
              <div class='border-2 rounded p-2'>
                Destination:
                <div>System: <%= assigns.ship.nav.route.destination.system_symbol %></div>
                <div>Waypoint: <%= assigns.ship.nav.route.destination.symbol %></div>
                <div>Type: <%= assigns.ship.nav.route.destination.type %></div>
                <div>Location: [<%= assigns.ship.nav.route.destination.x %>, <%= assigns.ship.nav.route.destination.y %>]</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_info({:ship_updated, ship}, socket) do
    {:noreply, socket |> assign(:ship, Spacetraders.Genservers.Ship.get(ship.symbol))}
  end
  def handle_event("dock", _, socket) do
    ship = socket.assigns.ship
    Spacetraders.Genservers.Ship.dock(ship.symbol)
    {:noreply, socket}
  end
  def handle_event("orbit", _, socket) do
    ship = socket.assigns.ship
    Spacetraders.Genservers.Ship.orbit(ship.symbol)
    {:noreply, socket}
  end
end
