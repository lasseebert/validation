defmodule Validation do
  @moduledoc """
  Contains top level convenience functions and macros that map into deeper modules
  """

  @doc """
  Creates a schema using the DSL
  """
  defmacro schema(schema_spec) do
    quote do
      require Validation.DSL
      Validation.DSL.build_schema(unquote(schema_spec))
    end
  end
end
