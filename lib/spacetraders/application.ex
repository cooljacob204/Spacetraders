defmodule Spacetraders.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SpacetradersWeb.Telemetry,
      # Start the Ecto repository
      Spacetraders.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Spacetraders.PubSub},
      # Start Finch
      {Finch, name: Spacetraders.Finch},
      # Start the Endpoint (http/https)
      SpacetradersWeb.Endpoint,
      # Start a worker by calling: Spacetraders.Worker.start_link(arg)
      # {Spacetraders.Worker, arg}
      Spacetraders.DynamicSupervisor,
      {Task, &Spacetraders.DynamicSupervisor.start_children/0}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spacetraders.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SpacetradersWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
