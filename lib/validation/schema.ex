defmodule Validation.Schema do
  @moduledoc """
  A Schema is a collection of rules that each are applied to the given params.
  The result of evaluating a params map against a schema is a %Result{} struct.
  """

  alias Validation.Result
  use Validation.Term

  @type application_result :: Result.t


  @doc """
  Builds a schema from a list of rules
  """
  @spec build([Rule.t]) :: t
  def build(rules) do
    build_term(rules: rules)
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

  def compile(_), do: raise("Not compilable")
end
