defmodule SpacetradersWeb.SystemsLive do
  use SpacetradersWeb, :live_view
  import Ecto.Query, only: [from: 2]

  def mount(params, _session, socket) do
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

    {:ok, socket |> assign(:systems, systems) |> assign(:lanes, lanes)}
  end

  def render(assigns) do
    ~H"""
      <header>
      </header>
      <content>
        <div class='bg-black' id="systemview" phx-update="ignore" ></div>
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

        lanes.forEach(function(lane) {
          g.append("line")
            .attr("x1", lane[0])
            .attr("y1", lane[1])
            .attr("x2", lane[2])
            .attr("y2", lane[3])
            .attr("stroke-width", 1)
            .attr("stroke", "white")
        })

        const systems = [<%= for system <- @systems do %><% {x, y} = system.position.coordinates %>{symbol: "<%= system.symbol %>",x: <%= x %>,y: <%= y %>,},<% end %>]

        systems.forEach(function(system) {
          g.append("circle")
            .attr("cx", system.x)
            .attr("cy", system.y)
            .attr("r", 10)
            .style("fill", "#FDB813")
        })

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
end
