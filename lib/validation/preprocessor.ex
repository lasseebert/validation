defmodule Validation.Preprocessor do
  @moduledoc """
  A Preprocessor transforms a params map.

  In a schema, an ordered list of preprocessors is applied before the rules.
  """

  import Kernel, except: [apply: 2]

  @type t :: %__MODULE__{val: preprocessor_fun, meta: meta_data}
  @typep params :: map
  @typep preprocessor_fun :: ((params) -> params)
  @typep meta_data :: Keyword.t

  defstruct [
    val: nil,
    meta: []
  ]

  @doc """
  Builds a custom preprocessor from a function and optionally some meta data.
  The function accepts a params map and returns an updated params map
  """
  @spec build(preprocessor_fun, meta_data) :: t
  def build(val, meta \\ []) do
    %__MODULE__{
      val: val,
      meta: meta
    }
  end

  @doc """
  Applies the preprocessor to the given params map
  """
  @spec apply(t, params) :: params
  def apply(%__MODULE__{val: val}, params) do
    val.(params)
  end

  @doc """
  Combines multiple preprocessors into a single preprocessor.
  The resulting preprocessor applies each given preprocessor in serial.
  """
  @spec combine([t]) :: t
  def combine(preprocessors) do
    val = fn params ->
      Enum.reduce(preprocessors, params, &apply/2)
    end
    build(val, type: "combined", preprocessors: preprocessors)
  end
end
