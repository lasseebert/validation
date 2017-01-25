defmodule Validation.Rules.Strict do
  @moduledoc """
  Rule that expects only the given keys
  """

  alias Validation.Rule

  @spec build(keys :: [any]) :: Rule.t
  def build(keys) do
    val = fn params ->
      params
      |> Enum.reject(fn {key, _value} -> key in keys end)
      |> Enum.map(fn {key, _value} -> {key, ["is not an expected key"]} end)
      |> Enum.into(%{})
    end

    Rule.build(val, [type: "strict", keys: keys])
  end
end
