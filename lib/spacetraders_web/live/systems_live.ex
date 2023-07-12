defmodule SpacetradersWeb.SystemsLive do
  use SpacetradersWeb, :live_view
  import Ecto.Query, only: [from: 2]

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <header>
      </header>
      <content>
        <div class='bg-black' id="systemview" phx-update="ignore"></div>
        <%= if assigns[:system] do %>
          <.modal id={"system"} show={true} on_cancel={JS.push("hide-system")}>
            <%= @system %>
          </.modal>
        <% end %>
      </content>
      <script type="module" id="script" phx-update="ignore">
        d3.select("html").attr("style", null);

        function handleZoom(e) {
          g.attr('transform', e.transform);
        }

        // Create the SVG container.
        const svg = d3.create("svg")
          .attr("width", window.innerWidth)
          .attr("height", window.innerHeight)

        const g = svg.append("g")

        svg.call(d3.zoom().on('zoom', handleZoom))

        async function getLanes() {
          return fetch("/api/systems/lanes")
            .then((response) => response.json())
            .then((data) => {
              return data.data
            })
        }

        let lanes = await getLanes()

        lanes.forEach((lane) => {
          g.append("line")
            .attr("x1", lane[0][0])
            .attr("y1", -lane[0][1])
            .attr("x2", lane[1][0])
            .attr("y2", -lane[1][1])
            .attr("stroke-width", 1)
            .attr("stroke", "white")
        })

        async function getSystems() {
          return fetch("/api/systems")
            .then((response) => response.json())
            .then((data) => {
              return data.data
            })
        }

        const systems = await getSystems()

        systems.forEach((system) => {
          g.append("circle")
            .attr("id", system.symbol)
            .attr("cx", system.position.coordinates[0])
            .attr("cy", -system.position.coordinates[1])
            .attr("r", 10)
            .attr("phx-value-symbol", system.symbol)
            .style("fill", "#FDB813")
            .attr("phx-click", "show-system")
            .on("mouseover", () => {appendSystemInfo(system)})
            .on("mouseout", () => {removeSystemInfo(system)})
        })

        async function getShips() {
          return fetch("/api/ships_and_their_systems")
            .then((response) => response.json())
            .then((data) => {
              return data.data
            })
        }

        const ships = await getShips()

        ships.forEach((ship) => {
          g.append("circle")
           .attr("cx", ship.system.position.coordinates[0])
           .attr("cy", -ship.system.position.coordinates[1])
           .attr("r", 10)
           .attr("phx-value-symbol", ship.system.symbol)
           .style("fill", "blue")
           .attr("phx-click", "show-system")
           .on("mouseover", () => {appendSystemInfo(ship.system)})
           .on("mouseout", () => {removeSystemInfo(ship.system)})
        })

        function appendSystemInfo(system) {
          console.log("mouseover " + system.symbol)
          const tooltip = svg.append('g')
                             .attr("id", system.symbol + "-info")
          tooltip.append("rect")
                 .attr("width", 120)
                 .attr("height", 50)
                 .attr("fill", "black")
                 .attr("stroke", "white")
                 .attr("stroke-width", 1)
                 .attr("x", 5)
                 .attr("y", 5)
          tooltip.append("text")
                 .attr("x", 15)
                 .attr("y", 39)
                 .style("fill", "white")
                 .style("stroke-width", 1)
                 .style("font-size", 24)
                 .text(system.symbol)
        }

        function removeSystemInfo(system) {
          console.log("mouseout " + system.symbol)
          d3.select("#" + system.symbol + "-info").remove()
        }

        // Append the SVG element.
        systemview.append(svg.node());

        function updateWindow(){
          const x = window.innerWidth;
          const y = window.innerHeight;

          svg.attr("width", x).attr("height", y);
        }
        d3.select(window).on('resize.updatesvg', updateWindow);
      </script>
    """
  end

  def handle_event("show-system", params, socket) do
    IO.puts inspect params
    {:noreply, socket |> assign(:system, params["symbol"])}
  end
  def handle_event("hide-system", _params, socket) do
    {:noreply, socket |> assign(:system, nil)}
  end
end
