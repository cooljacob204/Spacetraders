defmodule Spacetraders.Ship.Navigation.Route do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder
  embedded_schema do
    field :arrival, :utc_datetime
    field :departure_time, :utc_datetime
    embeds_one :departure, Spacetraders.Ship.Navigation.Route.Waypoint
    embeds_one :destination, Spacetraders.Ship.Navigation.Route.Waypoint
  end

  def changeset(route, attrs) do
    route
    |> cast(attrs, [:arrival, :departure_time])
    |> validate_required([:arrival, :departure_time, :departure, :destination])
    |> cast_embed(:departure, with: &Spacetraders.Ship.Navigation.Route.Waypoint.changeset/2)
    |> cast_embed(:destination, with: &Spacetraders.Ship.Navigation.Route.Waypoint.changeset/2)
  end
end
