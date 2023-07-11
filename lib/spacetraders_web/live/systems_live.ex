defmodule SpacetradersWeb.SystemsLive do
  use SpacetradersWeb, :live_view
  import Ecto.Query, only: [from: 2]

  def mount(_params, _session, socket) do
    systems = from(
      s in Spacetraders.System,
      select: s
    ) |> Spacetraders.Repo.all()
    lanes = from(
      l in Spacetraders.Lane,
        join: s in Spacetraders.System, on: l.arrival_system_id == s.id,
        join: j in Spacetraders.System, on: l.jump_system_id == j.id,
      select: {s.position, j.position}
    ) |> Spacetraders.Repo.all()

    {:ok, socket |> assign(:systems, systems) |> assign(:lanes, lanes) |> assign(:ships_and_their_system, ships_and_their_system())}
  end

  def render(assigns) do
    ~H"""
      <header>
      </header>
      <content>
        <%= if assigns[:system] do %>
          <.modal id={"system"} show={true} on_cancel={JS.push("hide-system")}>
            <%= @system %>
          </.modal>
        <% end %>
        <div class='bg-black' id="systemview" phx-update="ignore"></div>
      </content>
      <script type="module">
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

        const lanes = [<%= for lane <- @lanes do %><% {%{coordinates: {x1, y1}}, %{coordinates: {x2, y2}}} = lane %>[<%= x1 %>, <%= y1 %>, <%= x2 %>, <%= y2 %>],<% end %>]

        lanes.forEach((lane) => {
          g.append("line")
            .attr("x1", lane[0])
            .attr("y1", -lane[1])
            .attr("x2", lane[2])
            .attr("y2", -lane[3])
            .attr("stroke-width", 1)
            .attr("stroke", "white")
        })

        const systems = <%= raw(Jason.encode!(@systems)) %>

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

        const ships = <%= raw(Jason.encode!(@ships_and_their_system, escape: :html_safe)) %>

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

  defp ships_and_their_system do
    List.flatten(Enum.map(Spacetraders.Agent.list_agents(), fn agent ->
      agent = Spacetraders.Genservers.Agent.get(agent.symbol)
      Enum.map(agent.ships, fn ship ->
        ship = Spacetraders.ShipServer.get(ship)
        system = from(s in Spacetraders.System, where: s.symbol == ^ship.nav.system_symbol, select: s) |> Spacetraders.Repo.one()

        %{ship: ship, system: system}
      end)
    end))
  end
end
