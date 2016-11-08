defmodule Validation.Predicate do
  @moduledoc """
  A compiled predicate takes a single value as input and returns either
  :ok or {:error, message}.
  """

  defstruct [
    name: nil,
    fun: nil,
    message: nil
  ]

  @doc """
  Builds a predicate data structure.

  The given fun should return true or false when given a single input
  """
  def build(name, fun, message) do
    %__MODULE__{
      name: name,
      fun: fun,
      message: message
    }
  end

  @doc """
  Compiled the predicate into a function that accepts a single value argument
  and returns either :ok or {:error, message}
  """
  def compile(%__MODULE__{} = predicate) do
    fn value ->
      if predicate.fun.(value) do
        :ok
      else
        {:error, predicate.message}
      end
    end
  end
end
