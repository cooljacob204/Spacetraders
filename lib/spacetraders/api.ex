defmodule Spacetraders.Api do
  @base_url "https://api.spacetraders.io/v2"

  def get(agent, path, opts \\ []) do
    resp = parse_body(HTTPoison.get("#{@base_url}#{path}", headers(agent), opts))

    case resp do
      {:ok, %{status_code: 429} = resp} ->
        Process.sleep(round(resp.body["error"]["data"]["retry_after"] * 1000))
        get(agent, path, opts)
      _ -> handle_response(resp)
    end
  end
  def post(agent, path, body, opts \\ []) do
    resp = parse_body(HTTPoison.post("#{@base_url}#{path}", body, headers(agent), opts))

    case resp do
      {:ok, %{status_code: 429} = resp} ->
        Process.sleep(round(resp.body["error"]["data"]["retry_after"] * 1000))
        post(agent, path, body, opts)
      _ -> handle_response(resp)
    end
  end
  defp parse_body({:ok, %{body: body} = resp}), do:
    {:ok,
     %{resp | body: body
                    |> Jason.decode!()
                    |> ProperCase.to_snake_case()}
    }
  defp parse_body({:error, error}), do: {:error, error}
  defp handle_response({:ok, %{body: body}}), do: {:ok, body}
  defp handle_response({:error, %{reason: reason}}), do: {:error, reason}

  defp token(agent) do
    {"Authorization","Bearer #{agent.token}"}
  end

  defp headers(agent) do
    [token(agent), {"Content-Type", "application/json"}]
  end
end
