defmodule Spacetraders.Ship.Extraction do
  alias Spacetraders.Api

  def extract(ship, agent) do
    # return {:ok, :cargo_full} if ship.cargo.capacity == ship.cargo.units
    case Api.Ship.extract(agent, ship) do
      %{"data" => %{"cargo" => cargo, "cooldown" => %{"remaining_seconds" => cooldown}}} -> extracted(cargo,  cooldown)
      %{"error" => error} -> error(error)
    end
  end

  defp extracted(cargo, cooldown) do
    Process.send_after(self(), :extract_cooldown_ended, cooldown * 1000)

    {:ok, cargo}
  end

  defp error(%{"code" => 4000} = error) do
    cooldown = error["data"]["cooldown"]["remaining_seconds"]
    Process.send_after(self(), :extract_cooldown_ended, cooldown * 1000)

    {:ok, :cooldown}
  end
  defp error(%{"code" => 4228}), do:
    {:ok, :cargo_full}
  defp error(error) do
    {:error, error}
  end
end
