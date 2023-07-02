defmodule SpacetradersWeb.AgentsController do
  use SpacetradersWeb, :controller
  def index(conn, _params) do
    conn
    |> assign(:agents, Spacetraders.Agent.list_agents())
    |> render(:index)
  end
end
