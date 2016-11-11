defmodule Validation.Rule do
  @moduledoc """
  A rule accepts a %Result{} and returns an updated %Result{}
  """

  alias Validation.Result
  alias Validation.Validator

  defstruct [
    fun: nil,
    meta: []
  ]

  @doc """
  Build a custom rule from just a function.
  The function must accept a %Result and return an updated %Result{}
  """
  def build(fun, meta \\ []) do
    %__MODULE__{
      fun: fun,
      meta: meta
    }
  end

  @doc """
  Build a rule that validates a single value by key and a predicate
  """
  def build_value_rule(key, predicate) do
    compiled_predicate = Validator.compile(predicate)
    fun = fn result ->
      result.data
      |> Map.get(key)
      |> compiled_predicate.()
      |> case do
        :ok -> result
        {:error, message} -> Result.put_error(result, key, message)
      end
    end

    build(fun, [name: "value_rule", key: key, predicate: predicate])
  end

  @doc """
  Build a rule that requires a certain key to be present
  """
  def build_required_key(key) do
    fun = fn result ->
      result.data
      |> Map.has_key?(key)
      |> case do
        true -> result
        false -> Result.put_error(result, key, "is missing")
      end
    end

    build(fun, [name: "required_key_rule", key: key])
  end
end

defimpl Validation.Validator, for: Validation.Rule do
  def compile(rule) do
    rule.fun
  end
end
