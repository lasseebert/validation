defmodule Validation.Schema do
  @moduledoc """
  A Schema is a collection of rules that each are applied to the given params.
  The result of evaluating a params map against a schema is a %Result{} struct.
  """

  alias Validation.Preprocessor
  alias Validation.Result
  alias Validation.Rule

  @type t           :: %__MODULE__{val: schema_fun, meta: meta_data}
  @typep schema_fun :: ((map) -> Result.t)
  @typep meta_data  :: Keyword.t

  defstruct [
    val: nil,
    meta: []
  ]

  @doc """
  Builds a schema from a list of rules and optionally a preprocessor
  """
  @spec build([Rule.t], Preprocessor.t) :: t
  def build(rules, preprocessor \\ Preprocessor.identity) do
    val = fn params ->
      params = Preprocessor.apply(preprocessor, params)
      result = %Result{data: params}
      Enum.reduce(rules, result, fn rule, result ->
        errors = Rule.apply(rule, result.data)
        Result.merge_errors(result, errors)
      end)
    end

    %__MODULE__{val: val, meta: [rules: rules]}
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
