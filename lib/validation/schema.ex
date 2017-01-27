defmodule Validation.Schema do
  @moduledoc """
  A Schema is a collection of rules that each are applied to the given params.
  The result of evaluating a params map against a schema is a %Result{} struct.
  """

  alias Validation.Preprocessor
  alias Validation.Preprocessors.Identity
  alias Validation.Preprocessors.Whitelist
  alias Validation.Result
  alias Validation.Rule
  alias Validation.Rules.Strict
  import Kernel, except: [apply: 2]

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
  Builds a schema from a list of rules and nested schemas
  """
  @spec build([Rule.t], nested :: %{optional(any) => t}, options) :: t
  def build(rules, nested_schemas, options \\ []) do
    preprocessor = Keyword.get(options, :preprocessor, Identity.build)
    strict? = Keyword.get(options, :strict, false)
    whitelist? = Keyword.get(options, :whitelist, false)

    rules = if strict?, do: [strict_rule(rules) | rules], else: rules
    preprocessor = if whitelist?,
      do: Preprocessor.combine([preprocessor, whitelister(rules)]),
      else: preprocessor

    val = fn params ->
      params
      |> apply_preprocessor(preprocessor)
      |> build_result
      |> apply_rules(rules)
      |> apply_nested_schemas(nested_schemas)
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

  defp apply_preprocessor(params, preprocessor) do
    Preprocessor.apply(preprocessor, params)
  end

  defp build_result(params) do
    %Result{data: params}
  end

  defp apply_rules(result, rules) do
    Enum.reduce(rules, result, fn rule, result ->
      errors = Rule.apply(rule, result.data)
      Result.merge_errors(result, errors)
    end)
  end

  defp apply_nested_schemas(result, nested_schemas) do
    Enum.reduce(nested_schemas, result, fn {key, nested_schema}, result ->
      result.data
      |> Map.fetch(key)
      |> case do
        {:ok, %{} = nested_params} ->
          nested_result = apply(nested_schema, nested_params)
          Result.merge_nested(result, nested_result, key)
        {:ok, _not_map} ->
          Result.merge_errors(result, %{key => ["is invalid"]})
        :error ->
          result
      end
    end)
  end

  defp strict_rule(rules) do
    rules
    |> rule_keys
    |> Strict.build
  end

  defp whitelister(rules) do
    rules
    |> rule_keys
    |> Whitelist.build
  end

  defp rule_keys(rules) do
    rules
    |> Enum.filter(&(Keyword.has_key?(&1.meta, :key)))
    |> Enum.map(&(Keyword.fetch!(&1.meta, :key)))
  end
end
