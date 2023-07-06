defmodule Spacetraders.Ship.Cargo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Spacetraders.Ship.Cargo.Item

  embedded_schema do
    field :capacity, :integer
    field :units, :integer
    embeds_many :inventory, Item, on_replace: :delete
  end

  def changeset(fuel, attrs) do
    fuel
    |> cast(attrs, [:capacity, :units])
    |> validate_required([:capacity, :units])
    |> cast_embed(:inventory, with: &Item.changeset/2)
  end

  def sell_item(ship, %Item{} = item) do
    agent = Spacetraders.Genservers.Agent.get(ship.agent_symbol)

    case Spacetraders.Api.Ship.sell_item(agent, ship, item.symbol, item.units) do
      %{"data" => %{"cargo" => cargo, "agent" => agent, "transaction" => _transaction}} -> {:ok, cargo, agent}
      %{"error" => error } -> {:error, error}
    end
  end
end
