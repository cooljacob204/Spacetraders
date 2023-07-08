defmodule Spacetraders.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl DynamicSupervisor
    def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_children do
    for child <- Spacetraders.Genservers.Agent.children_list ++ Spacetraders.ShipServer.children_list do
      {:ok, _pid} = start_child(child)
    end

    :ok
  end

  def start_child(child) do
    DynamicSupervisor.start_child(__MODULE__, child)
  end
end
