defmodule Validation.Rule do
  @moduledoc """
  A rule accepts a %Result{} and returns an updated %Result{}
  """

  use   Validation.Term
  alias Validation.Result

  @typep application_result :: Result.t

  @spec build(compiled_fun, meta_data) :: t
  def build(compiled, meta) do
    %__MODULE__{compiled: compiled, meta: meta}
  end

  @doc """
  Built-in rule that validates a single value by key and a predicate
  """

  @spec built_in(String.t, any, Predicate.t | Schema.t) :: t
  def built_in("value", key, predicate) do
    build_term(type: "value", key: key, predicate: predicate)
  end

  def built_in("schema", key, schema) do
    build_term(type: "schema", key: key, schema: schema)
  end

  @doc """
  Build a rule that requires a certain key to be present
  """
  @spec built_in(String.t, any) :: t
  def built_in("required", key) do
    build_term(type: "required_key", key: key)
  end
end

defimpl Validation.Compilable, for: Validation.Rule do
  alias Validation.Predicate
  alias Validation.Schema
  alias Validation.Result
  alias Validation.Rule

  def compile(%Rule{meta: %{type: "value", key: key, predicate: pred}}) do
    fn(result) ->
      value = Map.get(result.data, key)

      case Predicate.apply(pred, value) do
        :ok               -> result
        {:error, message} -> Result.put_error(result, key, message)
      end
    end
  end

  def compile(%Rule{meta: %{type: "required_key", key: key}}) do
    fn(result) ->
      if Map.has_key?(result.data, key) do
        result
      else
        Result.put_error(result, key, "is missing")
      end
    end
  end

  def compile(%Rule{meta: %{type: "schema", key: key, schema: schema}}) do
    fn(result) ->
      value      = Map.get(result.data, key)
      new_result = Schema.apply(schema, value)

      if new_result.valid? do
        result
      else
        Result.put_error(result, key, new_result.errors)
      end
    end
  end

  def compile(_), do: raise("Not compilable")
end
