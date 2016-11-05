defmodule Validation.Result do
  @moduledoc """
  The result of a validation
  """

  defstruct [
    data: %{},
    errors: %{}
  ]

  def valid?(result) do
    result.errors == %{}
  end

  @doc """
  Adds a parameter to the data.
  """
  def put_data(result, key, value) do
    %{result | data: Map.put(result.data, key, value)}
  end

  @doc """
  Adds an error to a specific key
  """
  def put_error(result, key, message) do
    %{result | errors: Map.update(result.errors, key, [message], fn errors -> [message | errors] end)}
  end
end
