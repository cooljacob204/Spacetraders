defmodule Spacetraders.Ship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "/my/ships" do
    field :agent_symbol, :string
    field :symbol, :string
    embeds_one :nav, Spacetraders.Ship.Navigation
    field :crew, :any, virtual: true
    field :fuel, :any, virtual: true
    field :frame, :any, virtual: true
    field :reactor, :any, virtual: true
    field :engine, :any, virtual: true
    field :modules, {:array, :map}
    field :mounts, {:array, :map}
    embeds_one :registration, Spacetraders.Ship.Registration
    field :cargo, :any, virtual: true
  end

  def list_ships(agent) do
    ships = case Spacetraders.Api.Agent.get_ships(agent) do
      %{"data" => data} -> data
      %{"error" => error } -> raise "Error: #{error}"
    end

    Enum.map(ships, fn attrs ->
      changeset(%Spacetraders.Ship{agent_symbol: agent.symbol}, attrs)
      |> apply_changes()
    end)
  end

  def changeset(ship, attrs) do
    ship
    |> cast(attrs, [:agent_symbol, :symbol, :crew, :fuel, :frame, :reactor, :engine, :modules, :mounts, :cargo])
    |> cast_embed(:registration, with: &Spacetraders.Ship.Registration.changeset/2)
    |> cast_embed(:nav, with: &Spacetraders.Ship.Navigation.changeset/2)
    |> validate_required([:agent_symbol, :symbol, :nav, :crew, :fuel, :frame, :reactor, :engine, :modules, :mounts, :registration, :cargo])
  end
end
