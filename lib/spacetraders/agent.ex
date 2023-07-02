defmodule Spacetraders.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agents" do
    field :symbol, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:symbol, :token])
    |> validate_required([:symbol, :token])
  end
end
