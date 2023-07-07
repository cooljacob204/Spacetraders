defmodule Spacetraders.Repo.Migrations.CreateMarketTransactions do
  use Ecto.Migration

  def change do
    create table(:market_transactions) do
      add :waypoint_symbol, :string
      add :ship_symbol, :string
      add :trade_symbol, :string
      add :type, :string
      add :units, :integer
      add :price_per_unit, :integer
      add :total_price, :integer
      add :timestamp, :utc_datetime

      timestamps()
    end
  end
end
