defmodule Spacetraders.Ship.Cargo.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:symbol, :string, []}
  @derive Jason.Encoder
  embedded_schema do
    field :name, :string
    field :description, :string
    field :units, :integer
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:symbol, :name, :description, :units])
    |> validate_required([:symbol, :name, :description, :units])
  end
end
