defmodule Validation.ComposedPredicate do
  @moduledoc """
  A predicate that is composed of multiple other predicates
  """

  defstruct [
    predicates: [],
    compiler: nil,
    meta: []
  ]

  @doc """
  Build a composed predicate by supplying the underlaying predicates and a compiler function that composes them.
  The compiler takes a list of predicates as input and returns a function that accepts a value and returns either :ok or
  {:error, message}
  """
  def build(predicates, compiler, meta \\ []) do
    %__MODULE__{
      predicates: predicates,
      compiler: compiler,
      meta: meta
    }
  end
end

defimpl Validation.Validator, for: Validation.ComposedPredicate do
  def compile(composed) do
    composed.compiler.(composed.predicates)
  end
end
