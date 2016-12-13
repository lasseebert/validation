defmodule Validation.Rule do
  @moduledoc """
  A rule accepts a params map and returns an error map
  """

  alias Validation.Predicate

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

  @doc """
  Built-in rule that validates a single value by key and a predicate
  """
  @spec built_in(String.t, any, Predicate.t) :: t
  def built_in("value", key, predicate) do
    val = fn params ->
      value = Map.get(params, key)
      case Predicate.apply(predicate, value) do
        :ok -> %{}
        {:error, message} -> %{key => [message]}
      end
    end

    build(val, [type: "value", key: key, predicate: predicate])
  end

  @doc """
  Build a rule that requires a certain key to be present
  """
  @spec built_in(String.t, any) :: t
  def built_in("required", key) do
    val = fn params ->
      params
      |> Map.has_key?(key)
      |> case do
        true -> %{}
        false -> %{key => ["is missing"]}
      end
    end

    build(val, [type: "required_key", key: key])
  end

  @doc """
  Built-in rule that expects only the given keys
  """
  @spec built_in(String.t, [any]) :: t
  def built_in("strict", keys) do
    val = fn params ->
      params
      |> Enum.reject(fn {key, _value} -> key in keys end)
      |> Enum.map(fn {key, _value} -> {key, ["is not an expected key"]} end)
      |> Enum.into(%{})
    end

    build(val, [type: "strict", keys: keys])
  end
end
