defmodule Validation.Validator do
  @moduledoc """
  functions for validating a set of params against a schema
  """

  alias Validation.Result

  @doc """
  Validates a set of params against a schema.
  Returns a Validation.Result struct
  """
  def result(params, schema) do
    params
    |> Enum.into([])
    |> Enum.reduce(%Result{}, fn {key, value} = param, result ->
      case validate_param(param, schema) do
        :ok ->
          Result.put_data(result, key, value)
      end
    end)
  end

  def validate_param({_key, _value}, _schema) do
    :ok
  end
end
