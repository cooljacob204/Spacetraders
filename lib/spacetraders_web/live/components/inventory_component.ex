defmodule SpacetradersWeb.Live.InventoryComponent do
  use SpacetradersWeb, :live_component
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(:inventory, assigns.inventory) |> assign(:ship, assigns.ship)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= for item <- assigns.inventory do %>
        <div class='border-2 rounded my-1 p-1 flex flex-row justify-between'>
          <div>
            <div><label class='text-l font-bold'>Name:</label> <%= item.name %></div>
            <div><label class='text-l font-bold'>Amount:</label> <%= item.units %></div>
            <div><label class='text-l font-bold'>Description:</label> <%= item.description %></div>
          </div>
          <div>
            <.button phx-click="dump" phx-value-symbol={item.symbol} phx-value-units={item.units} phx-target={@myself}>dump</.button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("dump", %{"symbol" => symbol, "units" => units}, socket) do
    Spacetraders.ShipServer.dump_item(socket.assigns.ship.symbol, symbol, String.to_integer(units))

    {:noreply, socket}
  end
end
