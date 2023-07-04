defmodule Spacetraders.Ship.Navigation do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :system_symbol, :string
    field :waypoint_symbol, :string
    embeds_one :route, Spacetraders.Ship.Navigation.Route
    field :status, Ecto.Enum, values: [:IN_TRANSIT, :IN_ORBIT, :DOCKED]
    field :flight_mode, Ecto.Enum, values: [:DRIFT, :STEALTH, :CRUISE, :BURN], default: :CRUISE
  end

  def changeset(navigation, attrs) do
    navigation
    |> cast(attrs, [:system_symbol, :waypoint_symbol, :status, :flight_mode])
    |> validate_required([:system_symbol, :waypoint_symbol, :status, :flight_mode])
    |> cast_embed(:route, with: &Spacetraders.Ship.Navigation.Route.changeset/2)
  end
end
