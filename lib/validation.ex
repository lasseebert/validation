defmodule Validation do
  @moduledoc """
  Contains top level convenience functions and macros that map into deeper modules
  """

  @doc """
  Creates a schema using the DSL
  """
  defmacro schema(do: spec) do
    spec = Macro.escape(spec)
    quote do
      Validation.DSL.parse_schema(unquote(spec))
    end
  end
end
