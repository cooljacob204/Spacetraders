defmodule SpacetradersWeb.Live.JumpGateComponent do
  use SpacetradersWeb, :live_component

  def update(assigns, socket) do
    agent = Spacetraders.Genservers.Agent.get(assigns.ship.agent_symbol)
    waypoint = Spacetraders.Waypoint.get_waypoint(assigns.system.symbol, assigns.waypoint_symbol)
    jump_systems = Spacetraders.System.get_jump_systems(assigns.system)
    {:ok, socket |> assign(:ship, assigns.ship) |> assign(:system, assigns.system) |> assign(:waypoint, waypoint) |> assign(:jump_systems, jump_systems) |> assign(:agent, agent)}
  end

  def render(assigns) do
    ~H"""
      <div>
        <div class='text-lx font-bold'><%= @waypoint.symbol %></div>
        <div class='font-bold'><%= @waypoint.type %></div>
        <div>
          <%= for {distance, system} <- @jump_systems do %>
            <.modal id={"ship-#{system.symbol}-jumpgate-system"}>
              <.live_component
                module={SpacetradersWeb.Live.SystemComponent}
                id={"ship-#{system.symbol}-jumpgate-system-live"}
                ship={assigns.ship}
                agent={assigns.agent}
                system_symbol={system.symbol}
              />
            </.modal>
            <div class='flex flex-row justify-between border-2 rounded p-2 my-2'>
              <div>
                <div class='font-bold'><%= system.symbol %></div>
                <div><%= system.type %></div>
                <div><.coordinates coordinates={system.position.coordinates}/></div>
                <div><span>distance: </span><%= round(distance) %></div>
              </div>
              <div>
                <.button class='rounded-full bg-cyan-500 text-white px-4 py-2' phx-click={show_modal("ship-#{system.symbol}-jumpgate-system")}>System</.button>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    """
  end
end
