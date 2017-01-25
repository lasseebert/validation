defmodule Validation.Predicates.Filled do
  @moduledoc """
  Built-in predicate that validates that the value is filled.

  A value is considered filled if it is not nil and not "empty".
  """

  alias Validation.Predicate

  @spec build() :: Predicate.t
  def build do
    Predicate.build_basic(&filled?/1, "must be filled", "filled?")
  end

  defp filled?(value) when value in [nil, "", [], %{}], do: false
  defp filled?(_value), do: true
end
