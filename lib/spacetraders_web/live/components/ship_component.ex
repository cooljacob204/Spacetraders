defmodule SpacetradersWeb.ShipComponent do
  use SpacetradersWeb, :live_component

  def update(assigns, socket) do
    ship = Spacetraders.ShipServer.get(assigns.ship_symbol)
    Spacetraders.Ships.subscribe(ship)
    {:ok, socket |> assign(:ship, ship) |> assign(:agent, assigns.agent)}
  end

  def render(assigns) do
    ~H"""
    <div class='border-2 rounded p-2 m-1'>
      <.modal id={"ship-#{assigns.ship.symbol}-system"}>
        <.live_component module={SpacetradersWeb.Live.SystemComponent} id={"ship-#{assigns.ship.symbol}-system-live"} ship={assigns.ship} agent={assigns.agent}/>
      </.modal>
      <.modal id={"ship-#{assigns.ship.symbol}-inventory"}>
        <.live_component module={SpacetradersWeb.Live.InventoryComponent} id={"ship-#{assigns.ship.symbol}-inventory-live"} inventory={assigns.ship.cargo.inventory}/>
      </.modal>
      <div class='text-xl font-bold px-1 pt-2'><%= assigns.ship.symbol %> - <%= transition_description(assigns.ship) %></div>
      <div class='text-l font-bold px-1 pb-2'>Status: <%= assigns.ship.state %></div>
      <div class='flex flex-row gap-1'>
        <div class='grid gap-1 col-span-1 justify-items-stretch'>
          <div class='border-2 rounded p-2'>
            <div class='text-lg font-bold'>Registration</div>
            <div>Name: <%= assigns.ship.registration.name %></div>
            <div>Faction: <%= assigns.ship.registration.faction_symbol %></div>
            <div>Role: <%= assigns.ship.registration.role %></div>
          </div>
          <div class='border-2 rounded p-2'>
            <div class='text-lg font-bold'>Fuel</div>
            <div>Current: <%= assigns.ship.fuel.current %></div>
            <div>Capacity: <%= assigns.ship.fuel.capacity %></div>
          </div>
          <div class='border-2 rounded p-2'>
            <div class='text-lg font-bold'>Cargo</div>
            <div>Current: <%= assigns.ship.cargo.units %></div>
            <div>Capacity: <%= assigns.ship.cargo.capacity %></div>
            <.button class='rounded-full bg-cyan-500 text-white px-4 py-2 mt-2' phx-click={show_modal("ship-#{assigns.ship.symbol}-inventory")}>Inventory</.button>
          </div>
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
                  <.button class='rounded-full bg-cyan-500 text-white px-4 py-2' disabled={assigns.ship.state != :docked} phx-click="orbit" phx-target={@myself}>Orbit</.button>
                <% :IN_ORBIT -> %>
                  <.button class='rounded-full bg-cyan-500 text-white px-4 py-2' disabled={assigns.ship.state != :in_orbit} phx-click="dock" phx-target={@myself}>Dock</.button>
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

  defp transition_description(ship) do
    if ship.transition.callback do
      {:module, function_module} = Function.info(ship.transition.callback, :module)

      function_module.description()
    else
      case ship.state do
        :idle -> "Idle"
        :extracting -> "Extracting"
        :in_orbit -> "Idle in Orbit"
        :docked -> "Idle in Dock"
        :in_transit -> "In Transit"
        :selling_cargo -> "Selling Cargo"
      end
    end
  end

  def handle_event("dock", _, socket) do
    ship = socket.assigns.ship
    Spacetraders.ShipServer.dock(ship.symbol)
    {:noreply, socket}
  end
  def handle_event("orbit", _, socket) do
    ship = socket.assigns.ship
    Spacetraders.ShipServer.orbit(ship.symbol)
    {:noreply, socket}
  end
  def handle_event("sync", _, socket) do
    ship = socket.assigns.ship
    Spacetraders.ShipServer.sync(ship.symbol)
    {:noreply, socket}
  end
end
