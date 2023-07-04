defmodule SpacetradersWeb.Live.Components.System do
  use SpacetradersWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    # system = Spacetraders.Genservers.Systems.get(assigns.ship.agent_symbol, assigns.ship.nav.system_symbol)
    {:ok, socket |> assign(:test, "test")}
  end

  def render(assigns) do
    ~H"""
    <div>
      Hello world
      <%= assigns.test %>
    </div>
    """
  end
end
