defmodule SpacetradersWeb.Live.SystemComponent do
  alias Spacetraders.{Repo, Waypoint, System}
  use SpacetradersWeb, :live_component
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {system, waypoints} = if !socket.assigns[:ship] || assigns.ship.nav.waypoint_symbol != socket.assigns.ship.nav.waypoint_symbol do
      system = Repo.get_by(System, symbol: assigns.ship.nav.system_symbol)
      waypoints = Waypoint.get_systems_waypoints_with_distance(system, Repo.get_by(Waypoint, symbol: assigns.ship.nav.waypoint_symbol))

      {system, waypoints}
    else
      {socket.assigns.system, socket.assigns.waypoints}
    end
    {:ok, socket |> assign(:ship, assigns.ship) |> assign(:system, system) |> assign(:waypoints, waypoints)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class='p-2'>
        <div class='text-xl font-bold'><%= assigns.system.symbol %></div>
        <div><span class='font-bold'>Type:</span> <%= assigns.system.type %></div>
        <div><span class='font-bold'>Position:</span><.coordinates coordinates={assigns.system.position.coordinates}/></div>
      </div>
      <div class='text-lg font-bold mt-2 pt-2'>Waypoints</div>
      <div class=''>
        <%= for {waypoint, distance} <- assigns.waypoints do %>
          <div class='border-2 rounded my-1 p-1 flex flex-row justify-between'>
            <div>
              <div><span class='font-bold'>Symbol:</span> <%= waypoint.symbol %></div>
              <div><span class='font-bold'>Type:</span> <%= waypoint.type %></div>
              <div><span class='font-bold'>Position:</span><.coordinates coordinates={waypoint.position.coordinates}/></div>
              <div><span class='font-bold'>Distance:</span> <%= round(distance) %></div>
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
