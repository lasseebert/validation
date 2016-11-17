defmodule Validation.Schema do
  @moduledoc """
  A Schema is a collection of rules that each are applied to the given params.
  The result of evaluating a params map against a schema is a %Result{} struct.
  """

  alias Validation.Result
  alias Validation.Rule

  defstruct [
    val: nil,
    meta: []
  ]

  def build(rules) do
    val = fn params ->
      result = %Result{data: params}
      Enum.reduce(rules, result, &Rule.apply/2)
    end

    %__MODULE__{val: val, meta: [rules: rules]}
  end
end
