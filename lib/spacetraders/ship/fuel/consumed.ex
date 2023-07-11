defmodule Spacetraders.Ship.Fuel.Consumed do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder
  embedded_schema do
    field :amount, :integer
    field :timestamp, :utc_datetime
  end

  def changeset(consumed, attrs) do
    consumed
    |> cast(attrs, [:amount, :timestamp])
    |> validate_required([:amount, :timestamp])
  end
end
