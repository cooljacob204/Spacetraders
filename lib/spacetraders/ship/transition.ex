defmodule Spacetraders.Ship.Transition do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :callback, :any, virtual: true
    field :data, :any, virtual: true
  end

  def changeset(fuel, attrs) do
    fuel
    |> cast(attrs, [:callback, :data])
  end
end
