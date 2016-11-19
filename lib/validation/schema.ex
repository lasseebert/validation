defmodule Validation.Schema do
  @moduledoc """
  A Schema is a collection of rules that each are applied to the given params.
  The result of evaluating a params map against a schema is a %Result{} struct.
  """

  use Validation.Term

  @doc """
  Builds a schema from a list of rules
  """
  @spec build([Rule.t]) :: t
  def build(rules) do
    compile(rules: rules)
  end

  @doc """
  Applies the schema to a params map.
  Returns a %Result{} struct
  """
  @spec apply(t, map) :: Result.t
  def apply(%__MODULE__{val: val}, params) do
    val.(params)
  end
end

defimpl Validation.Compilable, for: Validation.Schema do
  alias Validation.Schema
  alias Validation.Rule
  alias Validation.Result

  def compile(%Schema{meta: %{rules: rules}}) do
    fn(params) ->
      result = %Result{data: params}

      Enum.reduce(rules, result, &Rule.apply/2)
    end
  end
end
