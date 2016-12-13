defmodule Validation.Schema do
  @moduledoc """
  A Schema is a collection of rules that each are applied to the given params.
  The result of evaluating a params map against a schema is a %Result{} struct.
  """

  alias Validation.Preprocessor
  alias Validation.Result
  alias Validation.Rule
  alias Validation.Rule.BuiltIn, as: BuiltInRule

  @type t :: %__MODULE__{val: schema_fun, meta: meta_data}
  @type options :: [option]
  @type option :: {:preprocessor, Preprocessor.t} | {:strict, boolean}
  @typep schema_fun :: ((map) -> Result.t)
  @typep meta_data :: Keyword.t

  defstruct [
    val: nil,
    meta: []
  ]

  @doc """
  Builds a schema from a list of rules and optionally a preprocessor
  """
  @spec build([Rule.t], options) :: t
  def build(rules, options \\ []) do
    preprocessor = Keyword.get(options, :preprocessor, Preprocessor.identity)
    strict? = Keyword.get(options, :strict, false)
    whitelist? = Keyword.get(options, :whitelist, false)

    rules = if strict?, do: [strict_rule(rules) | rules], else: rules
    preprocessor = if whitelist?,
      do: Preprocessor.combine([preprocessor, whitelister(rules)]),
      else: preprocessor

    val = fn params ->
      params = Preprocessor.apply(preprocessor, params)
      result = %Result{data: params}
      Enum.reduce(rules, result, fn rule, result ->
        errors = Rule.apply(rule, result.data)
        Result.merge_errors(result, errors)
      end)
    end

    %__MODULE__{val: val, meta: [rules: rules, preprocessor: preprocessor]}
  end

  @doc """
  Applies the schema to a params map.
  Returns a %Result{} struct
  """
  @spec apply(t, map) :: Result.t
  def apply(%__MODULE__{val: val}, params) do
    val.(params)
  end

  defp strict_rule(rules) do
    rules
    |> rule_keys
    |> BuiltInRule.strict
  end

  defp whitelister(rules) do
    rules
    |> rule_keys
    |> Preprocessor.whitelist
  end

  defp rule_keys(rules) do
    rules
    |> Enum.filter(&(Keyword.has_key?(&1.meta, :key)))
    |> Enum.map(&(Keyword.fetch!(&1.meta, :key)))
  end
end
