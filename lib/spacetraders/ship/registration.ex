defmodule Spacetraders.Ship.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :faction_symbol, :string
    field :role, :string
  end

  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:name, :faction_symbol, :role])
    |> validate_required([:name, :faction_symbol, :role])
  end
end
