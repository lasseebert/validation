defmodule Validation.Rule do
  @moduledoc """
  A single rule
  """

  defstruct [
    field: nil,
    key_rule: :optional,
    value_predicates: []
  ]

  # Everything below here operates on quoted expressions

  def build_rule({key_rule, _, [name, predicates]}) when key_rule in [:required, :optional] do
    %__MODULE__{
      field: name,
      key_rule: key_rule,
      value_predicates: build_predicates(predicates)
    }
  end

  # And-composition
  defp build_predicates({:and, _, [left, right]}) do
    {:and, build_predicates(left), build_predicates(right)}
  end

  # Predicate function with no arguments
  defp build_predicates({predicate_fun, _, nil}) do
    {predicate_fun, []}
  end

  # Predicate function with arguments
  defp build_predicates({predicate_fun, _, args}) do
    {predicate_fun, args}
  end
end

