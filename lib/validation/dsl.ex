defmodule Validation.DSL do
  @moduledoc """
  Functions that make it simple to create schemas
  """

  alias Validation.Predicates
  alias Validation.Rules
  alias Validation.Schema

  @type schema_ast :: any

  @doc """
  Creates a schema from the AST specification
  """
  @spec parse_schema(schema_ast) :: Schema.t
  def parse_schema(spec) do
    rules = parse_rules(spec)
    Schema.build(rules, %{})
  end

  defp parse_rules({:__block__, _, rules}) when is_list(rules) do
    rules
    |> Enum.flat_map(&parse_rules/1)
  end
  defp parse_rules({:required, _, [field]}) do
    key_rule = Rules.RequiredKey.build(field)
    [key_rule]
  end
  defp parse_rules({:required, _, [field, predicate_spec]}) do
    predicate = parse_predicate(predicate_spec)

    value_rule = Rules.Value.build(field, predicate)
    key_rule = Rules.RequiredKey.build(field)

    [key_rule, value_rule]
  end

  defp parse_predicate({:filled?, _, nil}) do
    Predicates.Filled.build
  end
end
