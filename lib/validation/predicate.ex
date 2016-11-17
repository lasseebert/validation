defmodule Validation.Predicate do
  @moduledoc """
  A predicate holds a function that accepts a single value
  and returns either :ok or {:error, message}
  """

  defstruct [
    val: nil,
    meta: []
  ]

  @doc """
  Builds a predicate data structure.
  """
  def build(val, meta \\ []) do
    %__MODULE__{
      val: val,
      meta: meta
    }
  end

  @doc """
  Build a basic predicate that validates a value and gives an error message
  The supplied fun should return true or false
  """
  def build_basic(fun, message, name) do
    val = fn value ->
      if fun.(value) do
        :ok
      else
        {:error, message}
      end
    end

    build(val, type: "basic", name: name, message: message)
  end

  @doc """
  Builds a predicate by composing multiple other predicates
  """
  def build_composed(predicates, composer, name) do
    val = composer.(predicates)
    build(val, type: "composed", name: name, predicates: predicates)
  end

  @doc """
  Applies the predicate to the given value.
  Returns :ok or {:error, message}
  """
  def apply(%__MODULE__{val: val}, value) do
    val.(value)
  end

  @doc """
  Built-in and
  """
  def built_in("and", left, right) do
    composer = fn [left, right] ->
      fn value ->
        with :ok <- left.val.(value) do
          right.val.(value)
        end
      end
    end

    build_composed([left, right], composer, "and")
  end

  @doc """
  Built-in filled?
  """
  def built_in("filled?") do
    build_basic(&filled?/1, "must be filled", "filled?")
  end

  defp filled?(value) when value in [nil, "", [], %{}], do: false
  defp filled?(_value), do: true
end
