defmodule Spacetraders.MarketTransaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Spacetraders.Repo

  schema "market_transactions" do
    field :price_per_unit, :integer
    field :ship_symbol, :string
    field :timestamp, :utc_datetime
    field :total_price, :integer
    field :trade_symbol, :string
    field :type, :string
    field :units, :integer
    field :waypoint_symbol, :string

    timestamps()
  end

  @doc false
  def changeset(market_transaction, attrs) do
    market_transaction
    |> cast(attrs, [:waypoint_symbol, :ship_symbol, :trade_symbol, :type, :units, :price_per_unit, :total_price, :timestamp])
    |> validate_required([:waypoint_symbol, :ship_symbol, :trade_symbol, :type, :units, :price_per_unit, :total_price, :timestamp])
  end

  def create(market_transaction) do
    Repo.insert(market_transaction)
  end
end
