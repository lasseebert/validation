defmodule Validation.Rules.Value do
  @moduledoc """
  Rule that validates a single value by key and a predicate
  """

  alias Validation.Predicate
  alias Validation.Rule

  @spec build(any, Predicate.t) :: Rule.t
  def build(key, predicate) do
    val = fn params ->
      value = Map.get(params, key)
      case Predicate.apply(predicate, value) do
        :ok -> %{}
        {:error, message} -> %{key => [message]}
      end
    end

    Rule.build(val, [type: "value", key: key, predicate: predicate])
  end
end
