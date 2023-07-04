defmodule Spacetraders.Api do
  @base_url "https://api.spacetraders.io/v2"

  def get(agent, path, opts \\ []) do
    case HTTPoison.get("#{@base_url}#{path}", headers(agent), opts) do
      {:ok, %{body: body}} ->
        body
        |> Jason.decode!()
        |> ProperCase.to_snake_case()
      {:error, %{reason: reason}} ->
        raise "Error: #{inspect(reason)}"
    end
  end

  def post(agent, path, opts \\ []) do
    case HTTPoison.post("#{@base_url}#{path}", "", headers(agent), opts) do
      {:ok, %{body: body}} ->
        body
        |> Jason.decode!()
        |> ProperCase.to_snake_case()
      {:error, %{reason: reason}} ->
        raise "Error: #{inspect(reason)}"
    end
  end

  defp token(agent) do
    {"Authorization","Bearer #{agent.token}"}
  end

  defp headers(agent) do
    [token(agent)]
  end
end
