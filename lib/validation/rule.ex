defmodule Validation.Rule do
  @moduledoc """
  A rule accepts a %Result{} and returns an updated %Result{}
  """

  alias Validation.Result

  defstruct [
    val: nil,
    meta: []
  ]

  @doc """
  Build a custom rule from just a function.
  The function must accept a %Result and return an updated %Result{}
  """
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
  def apply(%__MODULE__{val: val}, result) do
    val.(result)
  end

  @doc """
  Built-in rule that validates a single value by key and a predicate
  """
  def built_in("value", key, predicate) do
    val = fn result ->
      result.data
      |> Map.get(key)
      |> predicate.val.()
      |> case do
        :ok -> result
        {:error, message} -> Result.put_error(result, key, message)
      end
    end

    build(val, [type: "value", key: key, predicate: predicate])
  end

  @doc """
  Build a rule that requires a certain key to be present
  """
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
