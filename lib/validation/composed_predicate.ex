defmodule Validation.ComposedPredicate do
  @moduledoc """
  A predicate that is composed of multiple other predicates
  """

  defstruct [
    predicates: [],
    compiler: nil,
    meta: []
  ]

  alias Validation.Validator

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

  @doc """
  Builds a predicated composed by applying `and` to the given two predicates
  """
  def build_and(left, right) do
    compiler = fn [left, right] ->
      left_compiled = Validator.compile(left)
      right_compiled = Validator.compile(right)

      fn value ->
        with :ok <- left_compiled.(value) do
          right_compiled.(value)
        end
      end
    end

    build([left, right], compiler, name: "and")
  end
end

defimpl Validation.Validator, for: Validation.ComposedPredicate do
  def compile(composed) do
    composed.compiler.(composed.predicates)
  end
end
