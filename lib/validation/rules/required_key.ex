defmodule Validation.Rules.RequiredKey do
  @moduledoc """
  Rule that requires a certain key to be present
  """

  alias Validation.Rule

  @spec build(key :: any) :: Rule.t
  def build(key) do
    val = fn params ->
      params
      |> Map.has_key?(key)
      |> case do
        true -> %{}
        false -> %{key => ["is missing"]}
      end
    end

    Rule.build(val, [type: "required_key", key: key])
  end
end
