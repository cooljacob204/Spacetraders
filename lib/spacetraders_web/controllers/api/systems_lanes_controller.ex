defmodule SpacetradersWeb.Api.SystemsLanesController do
  use SpacetradersWeb, :controller
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    lanes = from(
      l in Spacetraders.Lane,
        join: s in Spacetraders.System, on: l.arrival_system_id == s.id,
        join: j in Spacetraders.System, on: l.jump_system_id == j.id,
      select: {s.position, j.position}
    ) |> Spacetraders.Repo.all()
      |> Enum.map(fn {%{coordinates: {j_x, j_y}}, %{coordinates: {a_x, a_y}}} -> [[j_x, j_y], [a_x, a_y]] end)

    json(conn, %{data: lanes})
  end
end
