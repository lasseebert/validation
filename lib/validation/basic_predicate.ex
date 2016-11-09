defmodule Validation.BasicPredicate do
  @moduledoc """
  The most basic form of predicates.
  This is the building block of other predicates
  """

  defstruct [
    fun: nil,
    message: nil,
    meta: []
  ]

  @doc """
  Builds a predicate data structure.

  The given fun should return true or false when given a single input
  """
  def build(fun, message, meta \\ []) do
    %__MODULE__{
      fun: fun,
      message: message,
      meta: meta
    }
  end

  @doc """
  Compiles the predicate into a function that accepts a single argument
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
