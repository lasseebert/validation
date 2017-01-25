defmodule Validation.Preprocessors.Whitelist do
  @moduledoc """
  A preprocessor that removes all the keys not in the given list
  """

  alias Validation.Preprocessor

  @spec build([keys :: any]) :: Preprocessor.t
  def build(keys) do
    val = fn params ->
      params
      |> Enum.filter(fn {key, _value} -> key in keys end)
      |> Enum.into(%{})
    end

    Preprocessor.build(val, type: "whitelist", keys: keys)
  end
end
