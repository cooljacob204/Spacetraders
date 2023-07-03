defmodule Spacetraders.Api do
  @base_url "https://api.spacetraders.io/v2"

  def get(agent, path, opts \\ []) do
    headers = [{"Authorization","Bearer #{agent.token}"}]

    case HTTPoison.get("#{@base_url}#{path}", headers, opts) do
      {:ok, %{body: body}} ->
        body
        |> Jason.decode!()
      {:error, %{reason: reason}} ->
        raise "Error: #{inspect(reason)}"
    end
  end
end
