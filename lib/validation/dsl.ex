defmodule Validation.DSL do
  @moduledoc """
  Functions that make it simple to create schemas
  """

  @doc """
  Creates a schema from the AST specification
  """
  defmacro build_schema(do: rule_spec) do
    quote do
      rules = Validation.DSL.parse_rules(unquote(rule_spec))
      Validation.Schema.build(rules, %{})
    end
  end

  defmacro parse_rules({:required, _, [field, predicate_spec]}) do
    quote do
      predicate = Validation.DSL.parse_predicate(unquote(predicate_spec))
      field = unquote(field)

      value_rule = Validation.Rules.Value.build(field, predicate)
      key_rule = Validation.Rules.RequiredKey.build(field)

      [key_rule, value_rule]
    end
  end

  defmacro parse_predicate({:filled?, _, nil}) do
    quote do
      Validation.Predicates.Filled.build
    end
  end
end
