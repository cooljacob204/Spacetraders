defmodule Spacetraders.Ship do
  use Ecto.Schema
  import Ecto.Changeset
  alias Spacetraders.{Ship, Ship.Registration, Ship.Navigation, Ship.Fuel, Ship.Cargo}

  schema "/my/ships" do
    field :state, Ecto.Enum, values: [:idle, :extracting, :in_orbit, :docked, :in_transit, :selling_cargo], default: :idle
    field :agent_symbol, :string
    field :symbol, :string
    embeds_one :nav, Navigation
    field :crew, :any, virtual: true
    embeds_one :fuel, Fuel
    field :frame, :any, virtual: true
    field :reactor, :any, virtual: true
    field :engine, :any, virtual: true
    field :modules, {:array, :map}
    field :mounts, {:array, :map}
    embeds_one :registration, Registration
    embeds_one :cargo, Cargo
  end

  def list_ships(agent) do
    ships = case Spacetraders.Api.Agent.get_ships(agent) do
      %{"data" => data} -> data
      %{"error" => error } -> raise "Error: #{error}"
    end

    Enum.map(ships, fn attrs ->
      state = case attrs["nav"]["status"] do
        "DOCKED" -> :docked
        "IN_ORBIT" -> :in_orbit
        "IN_TRANSIT" -> :in_transit
        _ -> :idle
      end

      changeset(%Ship{agent_symbol: agent.symbol, state: state}, attrs)
      |> apply_changes()
    end)
  end

  def changeset(ship, attrs) do
    ship
    |> cast(attrs, [:state, :agent_symbol, :symbol, :crew, :frame, :reactor, :engine, :modules, :mounts])
    |> validate_required([:state, :agent_symbol, :symbol, :nav, :crew, :fuel, :frame, :reactor, :engine, :modules, :mounts, :registration])
    |> cast_embed(:registration, with: &Registration.changeset/2)
    |> cast_embed(:nav, with: &Navigation.changeset/2)
    |> cast_embed(:fuel, with: &Fuel.changeset/2)
    |> cast_embed(:cargo, with: &Cargo.changeset/2)
  end
end
