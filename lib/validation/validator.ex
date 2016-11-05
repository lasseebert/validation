defmodule Validation.Validator do
  @moduledoc """
  functions for validating a set of params against a schema
  """

  alias Validation.Result
  alias Validation.Predicates

  @doc """
  Validates a set of params against a schema.
  Returns a Validation.Result struct
  """
  def result(params, schema) do
    rule_map =
      schema.rules
      |> Enum.map(&({&1.field, &1}))
      |> Enum.into(%{})

    params
    |> Enum.into([])
    |> Enum.reduce(%Result{}, fn {key, value}, result ->
      case validate_param(value, Map.get(rule_map, key)) do
        :ok ->
          result
          |> Result.put_data(key, value)
        {:error, message} ->
          result
          |> Result.put_data(key, value)
          |> Result.put_error(key, message)
        :no_rule ->
          result
      end
    end)
  end

  defp validate_param(_value, nil) do
    :no_rule
  end
  defp validate_param(value, rule) do
    validate_predicate(value, rule.value_predicates)
  end

  defp validate_predicate(value, {:and, left, right}) do
    with :ok <- validate_predicate(value, left) do
      validate_predicate(value, right)
    end
  end

  defp validate_predicate(value, {:filled?, []}) do
    if Predicates.filled?(value) do
      :ok
    else
      {:error, "must be filled"}
    end
  end

  defp validate_predicate(value, {:type?, [type]}) do
    if Predicates.type?(value, type) do
      :ok
    else
      {:error, "must be of type #{type}"}
    end
  end

  defp validate_predicate(value, {:match?, [pattern]}) do
    if Predicates.match?(value, pattern) do
      :ok
    else
      {:error, "is invalid"}
    end
  end
end
