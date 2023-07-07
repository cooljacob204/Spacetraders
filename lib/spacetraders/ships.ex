defmodule Spacetraders.Ships do
  alias Spacetraders.Ship

  def orbit(%Ship{state: :docked} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.orbit(agent(ship), ship)
    attrs = Map.put(attrs, "state", "in_orbit")

    {:ok, ship |> update(attrs)}
  end
  def orbit(ship), do: {{:error, "Ship not docked"}, ship}
  def dock(%Ship{state: :in_orbit} = ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.dock(agent(ship), ship)
    attrs = Map.put(attrs, "state", "docked")

    {:ok, ship |> update(attrs)}
  end
  def dock(ship), do: {{:error, "Ship not in orbit"}, ship}

  def extract(%Ship{state: :in_orbit} = ship) do
    case Ship.Extraction.extract(ship, agent(ship)) do
      {:ok, :cooldown} -> {:ok, ship |> update(%{state: :extracting})}
      {:ok, :cargo_full} -> {:ok, ship}
      {:ok, cargo} -> {:ok, ship |> update(%{state: :extracting, cargo: cargo})}
      {:error, error} -> {{:error, error}, ship}
    end
  end
  def extract(ship), do: {{:error, "Ship not in orbit"}, ship}

  def stop_extracting(%Ship{state: :extracting} = ship) do
    {:ok, ship |> update(%{state: :in_orbit})}
  end
  def stop_extracting(ship), do: {{:error, "Ship not extracting"}, ship}

  def extract_cooldown_ended(%Ship{state: :extracting} = ship) do
    case Ship.Extraction.extract(ship, agent(ship)) do
      {:ok, :cooldown} -> {:ok, ship}
      {:ok, :cargo_full} -> {:ok, ship |> update(%{state: :in_orbit})}
      {:ok, cargo} -> {:ok, ship |> update(%{state: :extracting, cargo: cargo})}
      {:error, error} -> {{:error, error}, ship}
    end
  end
  def extract_cooldown_ended(ship), do: {:ok, ship}

  def navigate(%Ship{state: :in_orbit} = ship, waypoint) do
    %{"data" => attrs} = Spacetraders.Api.Ship.navigate(agent(ship), ship, waypoint)
    attrs = Map.put(attrs, "state", "in_transit")

    ship = update(ship, attrs)

    {:ok, arrival_time, 0} = DateTime.from_iso8601(attrs["nav"]["route"]["arrival"])
    Process.send_after(self(), :navigation_complete, (DateTime.to_unix(arrival_time) - System.system_time(:second)) * 1000)

    {:ok, ship}
  end

  def navigation_complete(%Ship{state: :in_transit} = ship), do: {:ok, ship |> update(%{state: :in_orbit, nav: %{status: :IN_ORBIT}})}
  def navigation_complete(ship), do: {:ok, ship}

  def sell_cargo(%Ship{state: :docked, cargo: %{inventory: []}} = ship), do: {{:error, "cargo empty"}, ship}
  def sell_cargo(%Ship{state: :selling_cargo, cargo: %{inventory: []}} = ship), do: {:ok, ship |> update(%{state: :docked})}
  def sell_cargo(%Ship{state: :docked} = ship) do
    item_to_sell = hd ship.cargo.inventory

    case Ship.Cargo.sell_item(ship, item_to_sell) do
      {:ok, cargo, agent} ->
        Spacetraders.Genservers.Agent.update(agent["symbol"], agent)
        send(self(), :sell_cargo)
        {:ok, ship |> update(%{state: :selling_cargo, cargo: cargo})}
      {:error, error} -> {{:error, error}, ship}
    end
  end
  def sell_cargo(ship), do: {{:error, "Ship not docked"}, ship}

  def sync(ship) do
    %{"data" => attrs} = Spacetraders.Api.Ship.get_ship(agent(ship), ship.symbol)

    {:ok, ship |> update(attrs)}
  end

  def set_transition(ship, callback, data) do
    {:ok, ship |> update(%{transition: %{callback: callback, data: data}})}
  end

  defp update(ship, attrs) do
    updated_ship = ship
      |> Ship.changeset(attrs)
      |> Ecto.Changeset.apply_changes()

    broadcast({:ok, updated_ship}, :ship_updated)

    if updated_ship.state != ship.state do
      transition(ship, updated_ship)
    end

    updated_ship
  end
  defp transition(old_ship, ship) do
    if ship.transition.callback do
      ship.transition.callback.(ship, ship.state, old_ship.state, ship.transition.data)
    end
  end

  def subscribe(%Spacetraders.Ship{} = ship) do
    Phoenix.PubSub.subscribe(Spacetraders.PubSub, "ship-#{ship.symbol}")
  end

  defp broadcast({:ok, %Spacetraders.Ship{} = ship}, event) do
    Phoenix.PubSub.broadcast(Spacetraders.PubSub, "ship-#{ship.symbol}", {event, ship})

    {:ok, ship}
  end
  defp agent(%Ship{agent_symbol: agent_symbol}), do: Spacetraders.Genservers.Agent.get(agent_symbol)
end