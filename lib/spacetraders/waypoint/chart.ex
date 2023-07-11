defmodule Spacetraders.Waypoint.Chart do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :submitted_by, :string
    field :submitted_on, :utc_datetime
  end

  def changeset(faction, attrs) do
    faction
    |> cast(attrs, [:submitted_by, :submitted_on])
    |> validate_required([:submitted_by, :submitted_on])
  end
end
