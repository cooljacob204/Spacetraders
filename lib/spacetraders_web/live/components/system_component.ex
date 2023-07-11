defmodule SpacetradersWeb.Live.SystemComponent do
  alias Spacetraders.{Repo, Waypoint, System}
  use SpacetradersWeb, :live_component
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {system, waypoints} = if !socket.assigns[:ship] || assigns.ship.nav.waypoint_symbol != socket.assigns.ship.nav.waypoint_symbol do
      system = Repo.get_by(System, symbol: assigns.system_symbol)
      waypoints = if assigns[:waypoint_symbol] do
        Waypoint.get_systems_waypoints_with_distance(system, Repo.get_by(Waypoint, symbol: assigns.waypoint_symbol))
      else
        Waypoint.get_systems_waypoints_with_distance(system)
      end

      {system, waypoints}
    else
      {socket.assigns.system, socket.assigns.waypoints}
    end
    {:ok, socket |> assign(:ship, assigns.ship) |> assign(:system, system) |> assign(:waypoints, waypoints)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if assigns[:show_waypoint] do %>
        <.modal id={"system-#{assigns.ship.symbol}-#{assigns[:show_waypoint]}-waypoint"} show={true} on_cancel={JS.push("close-waypoint", target: @myself)}>
          <.live_component module={SpacetradersWeb.Live.WaypointComponent} id={"system-#{assigns.ship.symbol}-#{assigns[:show_waypoint]}-waypoint-live"} ship={assigns.ship} system={assigns.system} waypoint_symbol={assigns[:show_waypoint]}/>
        </.modal>
      <% end %>
      <%= if assigns[:show_jumpgate] do %>
        <.modal id={"system-#{assigns.ship.symbol}-#{assigns[:show_jumpgate]}-jumpgate"} show={true} on_cancel={JS.push("close-jumpgate", target: @myself)}>
          <.live_component module={SpacetradersWeb.Live.JumpGateComponent} id={"system-#{assigns.ship.symbol}-#{assigns[:show_jumpgate]}-jumpgate-live"} ship={assigns.ship} system={assigns.system} waypoint_symbol={assigns[:show_jumpgate]}/>
        </.modal>
      <% end %>
      <div class='p-2'>
        <div class='text-xl font-bold'><%= assigns.system.symbol %></div>
        <div><span class='font-bold'>Type:</span> <%= assigns.system.type %></div>
        <div><span class='font-bold'>Position:</span><.coordinates coordinates={assigns.system.position.coordinates}/></div>
      </div>
      <div class='text-lg font-bold mt-2 pt-2'>Waypoints</div>
      <div class=''>
        <%= for {waypoint, distance} <- assigns.waypoints do %>
          <div class='border-2 rounded my-1 p-1 flex flex-row justify-between'>
            <div class='flex flex-row'>
              <div class='p-2'>
                <div><span class='font-bold'>Symbol:</span> <%= waypoint.symbol %></div>
                <div><span class='font-bold'>Type:</span> <%= waypoint.type %></div>
                <div><span class='font-bold'>Position:</span><.coordinates coordinates={waypoint.position.coordinates}/></div>
                <div><span class='font-bold'>Distance:</span> <%= round(distance) %></div>
              </div>
              <div class='p-2'>
                <%= if waypoint.type == :JUMP_GATE do %>
                  <.button phx-click="show-jumpgate" value={waypoint.symbol} phx-target={@myself}>systems</.button>
                <% end %>
              </div>
            </div>
            <div class='p-2'>
              <.button phx-click="show-waypoint" value={waypoint.symbol} phx-target={@myself}>show</.button>
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
  def handle_event("show-waypoint", params, socket) do
    {:noreply, socket |> assign(:show_waypoint, params["value"])}
  end
  def handle_event("close-waypoint", _params, socket) do
    {:noreply, socket |> assign(:show_waypoint, nil)}
  end
  def handle_event("show-jumpgate", params, socket) do
    {:noreply, socket |> assign(:show_jumpgate, params["value"])}
  end
  def handle_event("close-jumpgate", _params, socket) do
    {:noreply, socket |> assign(:show_jumpgate, nil)}
  end
end
