defmodule SpacetradersWeb.Live.InventoryComponent do
  use SpacetradersWeb, :live_component
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(:inventory, assigns.inventory)}
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
            <.button disabled={true}>sell</.button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
