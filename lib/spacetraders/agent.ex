defmodule Spacetraders.Agent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Spacetraders.Repo

  schema "agents" do
    field :symbol, :string
    field :token, :string, redact: true

    field :account_id, :string, virtual: true
    field :credits, :integer, virtual: true
    field :starting_faction, :string, virtual: true
    field :headquarters, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:symbol, :token, :account_id, :credits, :starting_faction, :headquarters])
    |> validate_required([:symbol, :token])
  end

  def list_agents do
    Repo.all(Spacetraders.Agent)
  end
end
