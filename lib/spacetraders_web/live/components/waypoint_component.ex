defmodule SpacetradersWeb.Live.WaypointComponent do
  use SpacetradersWeb, :live_component

  def update(assigns, socket) do
    agent = Spacetraders.Genservers.Agent.get(assigns.ship.agent_symbol)
    {_, waypoint} = Spacetraders.Waypoint.get_latest_waypoint(agent, assigns.system.symbol, assigns.waypoint_symbol)
    {:ok, socket |> assign(:ship, assigns.ship) |> assign(:system, assigns.system) |> assign(:waypoint, waypoint)}
  end

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <div class='text-xl font-bold'><%= @waypoint.symbol %></div>
          <div class='font-bold'><%= @waypoint.type %></div>
          <div class='font-bold'><.coordinates coordinates={@waypoint.position.coordinates}/></div>
          <div class='font-bold'><%= if @waypoint.chart do%>charted<% else %>not charted<% end %></div>
        </div>
        <%= if length(@waypoint.traits) > 0 do %>
          <div class='text-lg font-bold mt-2 pt-2'>Traits</div>
        <% end %>
        <%= for trait <- @waypoint.traits do %>
          <div class='border-2 rounded p-2 my-2'>
            <div class='font-bold'><%= trait.name %></div>
            <div><%= trait.description %></div>
          </div>
        <% end %>
      </div>
    """
  end
end
