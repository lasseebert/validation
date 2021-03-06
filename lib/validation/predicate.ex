defmodule Validation.Predicate do
  @moduledoc """
  A predicate holds a function that accepts a single value
  and returns either :ok or {:error, message}
  """

  @type t :: %__MODULE__{val: compiled_fun, meta: meta_data}
  @type result :: :ok | {:error, String.t}
  @type compiled_fun :: ((any) -> result)
  @type meta_data :: Keyword.t

  defstruct [
    val: nil,
    meta: []
  ]

  @doc """
  Builds a predicate data structure.
  """
  @spec build(compiled_fun, meta_data) :: t
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
  @typep predicate_fun :: ((any) -> boolean)
  @spec build_basic(predicate_fun, String.t, String.t) :: t
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
  @spec build_composed([t], ([t] -> compiled_fun), String.t) :: t
  def build_composed(predicates, composer, name) do
    val = composer.(predicates)
    build(val, type: "composed", name: name, predicates: predicates)
  end

  @doc """
  Applies the predicate to the given value.
  Returns :ok or {:error, message}
  """
  @spec apply(t, any) :: result
  def apply(%__MODULE__{val: val}, value) do
    val.(value)
  end
end
