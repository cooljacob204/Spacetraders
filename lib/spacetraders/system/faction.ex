defmodule Spacetraders.System.Faction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field :symbol, Ecto.Enum, values: [:COSMIC, :VOID, :GALACTIC, :QUANTUM, :DOMINION, :ASTRO, :CORSAIRS, :OBSIDIAN, :AEGIS, :UNITED, :SOLITARY, :COBALT, :OMEGA, :ECHO, :LORDS, :CULT, :ANCIENTS, :SHADOW, :ETHEREAL]
  end

  def changeset(faction, attrs) do
    faction
    |> cast(attrs, [:symbol])
    |> validate_required([:symbol])
  end
end
