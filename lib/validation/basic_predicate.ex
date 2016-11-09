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
end

defimpl Validation.Validator, for: Validation.BasicPredicate do
  def compile(basic) do
    fn value ->
      if basic.fun.(value) do
        :ok
      else
        {:error, basic.message}
      end
    end
  end
end
