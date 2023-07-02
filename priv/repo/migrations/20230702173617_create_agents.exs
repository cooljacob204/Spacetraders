defmodule Spacetraders.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :symbol, :string
      add :token, :string

      timestamps()
    end
  end
end
