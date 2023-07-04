defmodule Spacetraders.System.Faction do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :symbol, Ecto.Enum, values: [:COSMIC, :VOID, :GALACTIC, :QUANTUM, :DOMINION, :ASTRO, :CORSAIRS, :OBSIDIAN, :AEGIS, :UNITED, :SOLITARY, :COBALT, :OMEGA, :ECHO, :LORDS, :CULT, :ANCIENTS, :SHADOW, :ETHEREAL]
  end

  def changeset(faction, attrs) do
    faction
    |> cast(attrs, [:symbol, :type, :x, :y])
    |> validate_required([:symbol, :type, :x, :y])
  end
end
