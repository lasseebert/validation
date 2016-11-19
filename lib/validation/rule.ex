defmodule Validation.Rule do
  @moduledoc """
  A rule accepts a %Result{} and returns an updated %Result{}
  """

  alias Validation.Predicate
  alias Validation.Result
  alias Validation.Schema

  @type t          :: %__MODULE__{val: rule_fun, meta: meta_data}
  @typep rule_fun  :: ((Result.t) -> Result.t)
  @typep meta_data :: Keyword.t

  defstruct [
    val: nil,
    meta: []
  ]

  @doc """
  Build a custom rule from just a function.
  The function must accept a %Result and return an updated %Result{}
  """
  @spec build(rule_fun, meta_data) :: t
  def build(val, meta \\ []) do
    %__MODULE__{
      val: val,
      meta: meta
    }
  end

  @doc """
  Applies the rule to the given result.
  Returns an updated result
  """
  @spec apply(t, Result.t) :: Result.t
  def apply(%__MODULE__{val: val}, result) do
    val.(result)
  end

  @doc """
  Built-in rule that validates a single value by key and a predicate
  """
  @spec built_in(String.t, any, Predicate.t) :: t
  def built_in("value", key, predicate) do
    val = fn result ->
      value = Map.get(result.data, key)
      case Predicate.apply(predicate, value) do
        :ok               -> result
        {:error, message} -> Result.put_error(result, key, message)
      end
    end

    build(val, [type: "value", key: key, predicate: predicate])
  end

  # FIXME: it's odd that Rule depends on Schema and Schema depends on Rule.
  # Both should probably depend on a common abstraction
  def built_in("schema", key, schema) do
    val = fn(result) ->
      value      = Map.get(result.data, key)
      new_result = Schema.apply(schema, value)

      if new_result.valid? do
        result
      else
        Result.put_error(result, key, new_result.errors)
      end
    end

    build(val, type: "schema", key: key, schema: schema)
  end

  @doc """
  Build a rule that requires a certain key to be present
  """
  @spec built_in(String.t, any) :: t
  def built_in("required", key) do
    val = fn result ->
      result.data
      |> Map.has_key?(key)
      |> case do
        true -> result
        false -> Result.put_error(result, key, "is missing")
      end
    end

    build(val, [type: "required_key", key: key])
  end
end
