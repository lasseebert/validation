defmodule Validation.Rule do
  @moduledoc """
  A rule accepts a %Result{} and returns an updated %Result{}
  """

  alias Validation.Predicate
  alias Validation.Result

  @type t         :: %__MODULE__{ val: rule_fun, meta: meta_data }
  @type rule_fun  :: ((Result.t) -> Result.t)
  @type meta_data :: Keyword.t

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
  @spec built_in(String.t, Any.t, Predicate.t) :: t
  def built_in("value", key, predicate) do
    val = fn result ->
      value = Map.get(result.data, key)
      case Predicate.apply(predicate, value) do
        :ok -> result
        {:error, message} -> Result.put_error(result, key, message)
      end
    end

    build(val, [type: "value", key: key, predicate: predicate])
  end

  @doc """
  Build a rule that requires a certain key to be present
  """
  @spec built_in(String.t, Any.t) :: t
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
