defmodule Spacetraders.Lane do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lanes" do
    field :jump_system_id, :id
    field :arrival_system_id, :id
    field :distance, :float

    timestamps()
  end

  @doc false
  def changeset(lane, attrs) do
    lane
    |> cast(attrs, [:jump_system_id, :arrival_system_id, :distance])
    |> validate_required([:jump_system_id, :arrival_system_id, :distance])
  end
end
