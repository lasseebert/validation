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

  def result(params, _schema) do
    # Dummy for now
    %{
      errors: %{},
      valid?: true,
      data: params
    }
  end
end
