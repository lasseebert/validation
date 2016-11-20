defmodule Validation.Predicate do
  @moduledoc """
  A predicate holds a function that accepts a single value
  and returns either :ok or {:error, message}
  """

  use Validation.Term.Primitive

  @doc """
  Build a basic predicate that validates a value and gives an error message
  The supplied fun should return true or false
  """

  @typep predicate_fun :: ((any) -> boolean)
  @spec  build_basic(predicate_fun, String.t, String.t) :: t
  def build_basic(fun, message, name) do
    build_term(type: "basic", name: name, message: message, fun: fun)
  end

  @doc """
  Builds a predicate by composing multiple other predicates
  """

  @typep composer :: (([t]) -> compilation)
  @spec  build_composed([t], composer, String.t) :: t
  def build_composed(predicates, composer, name) do
    build_term(type: "composed", name: name, predicates: predicates, combinator: composer)
  end

  @doc """
  Built-in and
  """
  @spec built_in(String.t, t, t) :: t
  def built_in("and", left, right) do
    build_composed([left, right], junctor("and"), "and")
  end

  @doc """
  Built-in or
  """
  def built_in("or", left, right) do
    build_composed([left, right], junctor("or"), "and")
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

  defp junctor(kind) do
    fn([left, right]) -> do_junctor(kind, left, right) end
  end

  defp do_junctor("and", left, right) do
    fn(value) ->
      with :ok <- left.compiled.(value), do: right.compiled.(value)
    end
  end

  defp do_junctor("or", left, right) do
    fn(value) ->
      case left.compiled.(value) do
        :ok -> succeed
        _   -> right.compiled.(value)
      end
    end
  end
end

defimpl Validation.Compilable, for: Validation.Predicate do
  alias Validation.Predicate

  def compile(%Predicate{meta: %{type: "basic", fun: fun, message: message}}) do
    compiled = fn(value) ->
      if fun.(value), do: Predicate.succeed, else: Predicate.fail(message)
    end

    {:ok, compiled}
  end

  def compile(%Predicate{meta: %{type: "composed", predicates: preds, combinator: comb}}) do
    {:ok, comb.(preds)}
  end
end
