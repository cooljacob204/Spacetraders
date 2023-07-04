defmodule SpacetradersWeb.ShipComponent do
  use SpacetradersWeb, :live_component

  def update(assigns, socket) do
    ship = Spacetraders.Genservers.Ship.get(assigns.ship_symbol)
    Spacetraders.Genservers.Ship.subscribe(ship)
    {:ok, socket |> assign(:ship, ship) |> assign(:agent, assigns.agent)}
  end

  def render(assigns) do
    ~H"""
    <div class='border-2 rounded p-2 m-1'>
      <.modal id={"ship-#{assigns.ship.symbol}-system"}>
        <.live_component module={SpacetradersWeb.Live.SystemComponent} id={"ship-#{assigns.ship.symbol}-system-live"} ship={assigns.ship} agent={assigns.agent}/>
      </.modal>
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
              <%= case assigns.ship.nav.status do %>
                <% :DOCKED -> %>
                  <.button class='rounded-full bg-cyan-500 text-white px-4 py-2' phx-click="orbit" phx-target={@myself}>Orbit</.button>
                <% :IN_ORBIT -> %>
                  <.button class='rounded-full bg-cyan-500 text-white px-4 py-2' phx-click="dock" phx-target={@myself}>Dock</.button>
                <% _ -> %>
              <% end %>
                <.button class='rounded-full bg-cyan-500 text-white px-4 py-2' phx-click={show_modal("ship-#{assigns.ship.symbol}-system")}>System</.button>
                <.button class='rounded-full bg-cyan-500 text-white px-4 py-2' phx-click="sync" phx-target={@myself}>Sync</.button>
            </div>
          </div>
          <div class='border-2 rounded p-2'>
            <div class='font-bold'>Route</div>
            <div>
              <div>Arrival: <%= Calendar.strftime(DateTime.shift_zone!(assigns.ship.nav.route.arrival, "America/New_York"),  "%y-%m-%d %I:%M:%S %p") %></div>
              <div>Departure: <%= Calendar.strftime(DateTime.shift_zone!(assigns.ship.nav.route.departure_time, "America/New_York"),  "%y-%m-%d %I:%M:%S %p") %></div>
            </div>
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
  def handle_event("sync", _, socket) do
    ship = socket.assigns.ship
    Spacetraders.Genservers.Ship.sync(ship.symbol)
    {:noreply, socket}
  end
end
