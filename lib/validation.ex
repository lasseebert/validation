defmodule Validation do
  @moduledoc """
  Describe a full usage of Validation here
  """

  @doc """
  Shorthand for Validation.Schema.define/1
  """
  defmacro schema(do: rules) do
    quote do
      require Validation.Schema
      Validation.Schema.define do
        unquote(rules)
      end
    end
  end

  @doc """
  Shorthand for Validation.Validator.result/2
  """
  def result(params, schema) do
    Validation.Validator.result(params, schema)
  end
end
