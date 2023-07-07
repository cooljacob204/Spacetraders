defmodule Spacetraders.Api do
  @base_url "https://api.spacetraders.io/v2"

  def get(agent, path, opts \\ []), do: handle_response(HTTPoison.get("#{@base_url}#{path}", headers(agent), opts))
  def post(agent, path, body, opts \\ []), do: handle_response(HTTPoison.post("#{@base_url}#{path}", body, headers(agent), opts))
  defp handle_response({:ok, %{body: body}}), do: {:ok, body |> Jason.decode!() |> ProperCase.to_snake_case()}
  defp handle_response({:error, %{reason: reason}}), do: {:error, reason}

  defp token(agent) do
    {"Authorization","Bearer #{agent.token}"}
  end

  defp headers(agent) do
    [token(agent), {"Content-Type", "application/json"}]
  end
end
