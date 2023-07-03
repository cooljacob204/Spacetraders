defmodule Spacetraders.Contract do
  import Ecto.Changeset
  defstruct [:id, :faction_symbol, :type, :terms, :accepted, :fulfilled, :expiration, :deadline_to_accept]

  def changeset(contract, attrs) do
    types = %{
      id: :string,
      faction_symbol: :string,
      type: :string,
      terms: :any,
      accepted: :boolean,
      fulfilled: :boolean,
      expiration: :string,
      deadline_to_accept: :string
    }

    {contract, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required([:id, :faction_symbol, :type, :terms, :accepted, :fulfilled, :expiration, :deadline_to_accept])
  end
end
