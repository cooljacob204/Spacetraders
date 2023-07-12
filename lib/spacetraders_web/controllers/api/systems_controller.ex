defmodule SpacetradersWeb.Api.SystemsController do
  use SpacetradersWeb, :controller
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    systems = from(
      s in Spacetraders.System,
      select: s
    ) |> Spacetraders.Repo.all()

    json(conn, %{data: systems})
  end
end
