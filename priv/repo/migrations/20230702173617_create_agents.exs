defmodule Spacetraders.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :symbol, :string, null: false
      add :token, :text, null: false

      timestamps()
    end
  end
end
