defmodule Validation.Rule do
  @moduledoc """
  A rule accepts a params map and returns an error map
  """

  @type t          :: %__MODULE__{val: rule_fun, meta: meta_data}
  @typep rule_fun  :: ((map) -> map)
  @typep meta_data :: Keyword.t

  defstruct [
    val: nil,
    meta: []
  ]

  @doc """
  Build a custom rule from just a function.
  The function must accept a %Result and return an updated %Result{}
  """
  @spec build(rule_fun, meta_data) :: t
  def build(val, meta \\ []) do
    %__MODULE__{
      val: val,
      meta: meta
    }
  end

  @doc """
  Applies the rule to the given input map.
  Returns an error map
  """
  @spec apply(t, map) :: map
  def apply(%__MODULE__{val: val}, result) do
    val.(result)
  end
end
