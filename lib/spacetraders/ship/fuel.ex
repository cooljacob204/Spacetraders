defmodule Spacetraders.Ship.Fuel do
  use Ecto.Schema
  import Ecto.Changeset
  alias Spacetraders.Ship.Fuel.Consumed

  embedded_schema do
    field :current, :integer
    field :capacity, :integer
    embeds_one :consumed, Consumed
  end

  def changeset(fuel, attrs) do
    fuel
    |> cast(attrs, [:current, :capacity])
    |> validate_required([:current, :capacity])
    |> cast_embed(:consumed, with: &Consumed.changeset/2)
  end
end
