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

  defmodule BuiltIn do
    alias Validation.Rule

    @moduledoc """
    Built-in rules
    """

    @doc """
    Rule that validates a single value by key and a predicate
    """
    @spec value(any, Predicate.t) :: Rule.t
    def value(key, predicate) do
      val = fn params ->
        value = Map.get(params, key)
        case Predicate.apply(predicate, value) do
          :ok -> %{}
          {:error, message} -> %{key => [message]}
        end
      end

      Rule.build(val, [type: "value", key: key, predicate: predicate])
    end

    @doc """
    Rule that requires a certain key to be present
    """
    @spec required_key(any) :: Rule.t
    def required_key(key) do
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

    @doc """
    Rule that expects only the given keys
    """
    @spec strict([any]) :: Rule.t
    def strict(keys) do
      val = fn params ->
        params
        |> Enum.reject(fn {key, _value} -> key in keys end)
        |> Enum.map(fn {key, _value} -> {key, ["is not an expected key"]} end)
        |> Enum.into(%{})
      end

      Rule.build(val, [type: "strict", keys: keys])
    end
  end
end
