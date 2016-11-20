defmodule Validation.Schema do
  @moduledoc """
  A Schema is a collection of rules that each are applied to the given params.
  The result of evaluating a params map against a schema is a %Result{} struct.
  """

  alias Validation.{Result, Rule}
  use Validation.Term.Compound

  @doc """
  Builds a schema from a list of rules
  """
  @spec build([Rule.t]) :: t
  def build(rules), do: build_term(rules: rules)
end

defimpl Validation.Compilable, for: Validation.Schema do
  alias Validation.Schema
  alias Validation.Rule
  alias Validation.Result

  def compile(%Schema{meta: %{rules: rules}}) do
    compiled = fn(params) ->
      result = %Result{data: params}

      Enum.reduce(rules, result, &Rule.apply/2)
    end

    {:ok, compiled}
  end

  def compile(_), do: {:error, "Invalid schema configuration"}
end
