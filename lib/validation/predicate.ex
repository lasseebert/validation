defmodule Validation.Predicate do
  @moduledoc """
  A predicate holds a function that accepts a single value
  and returns either :ok or {:error, message}
  """

  use Validation.Term

  @typep application_result :: :ok | {:error, String.t}

  @doc """
  Build a basic predicate that validates a value and gives an error message
  The supplied fun should return true or false
  """

  @typep predicate_fun :: ((any) -> boolean)
  @spec build_basic(predicate_fun, String.t, String.t) :: t
  def build_basic(fun, message, name) do
    build_term(type: "basic", name: name, message: message, fun: fun)
  end

  @doc """
  Builds a predicate by composing multiple other predicates
  """

  @typep composer :: (([t]) -> compiled_fun)
  @spec build_composed([t], composer, String.t) :: t
  def build_composed(predicates, composer, name) do
    build_term(type: "composed", name: name, predicates: predicates, combinator: composer)
  end

  @doc """
  Built-in and
  """
  @spec built_in(String.t, t, t) :: t
  def built_in("and", left, right) do
    composer = fn [left, right] ->
      fn value ->
        with :ok <- left.compiled.(value) do
          right.compiled.(value)
        end
      end
    end

    build_composed([left, right], composer, "and")
  end

  @doc """
  Built-in filled?
  """
  @spec built_in(String.t) :: t
  def built_in("filled?") do
    build_basic(&filled?/1, "must be filled", "filled?")
  end

  defp filled?(value) when value in [nil, "", [], %{}], do: false
  defp filled?(_value), do: true
end

defimpl Validation.Compilable, for: Validation.Predicate do
  alias Validation.Predicate

  def compile(%Predicate{meta: %{type: "basic", fun: fun, message: message}}) do
    fn(value) ->
      if fun.(value), do: :ok, else: {:error, message}
    end
  end

  def compile(%Predicate{meta: %{type: "composed", predicates: preds, combinator: comb}}) do
    comb.(preds)
  end
end
