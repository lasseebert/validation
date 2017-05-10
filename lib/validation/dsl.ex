defmodule Validation.DSL do
  @moduledoc """
  Functions that make it simple to create schemas
  """

  @doc """
  Creates a schema from the AST specification
  """
  defmacro build_schema(do: rule_spec) do
    rule_spec = Macro.escape(rule_spec)
    quote do
      rules = Validation.DSL.parse_rules(unquote(rule_spec))
      Validation.Schema.build(rules, %{})
    end
  end

  def parse_rules({:required, _, [field, predicate_spec]}) do
    predicate = parse_predicate(predicate_spec)

    value_rule = Validation.Rules.Value.build(field, predicate)
    key_rule = Validation.Rules.RequiredKey.build(field)

    [key_rule, value_rule]
  end

  defp parse_predicate({:filled?, _, nil}) do
    Validation.Predicates.Filled.build
  end
end
