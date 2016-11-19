defmodule Validation.Term do
  @moduledoc """
  A term is a part of the validation algebra that can be compiled
  """

  defmacro __using__(_opts) do
    quote do
      import Validation.Compilable, only: [compile: 1]

      @type t             :: %__MODULE__{compiled: compiled_fun, meta: meta_data}
      @typep compiled_fun :: ((any) -> application_result)
      @typep meta_data    :: Keyword.t

      defstruct compiled: nil, meta: %{}

      @spec build_term(Keyword.t) :: t
      def build_term(meta \\ []) do
        term = meta
                |> Enum.into(%{})
                |> new

        %{term | compiled: compile(term)}
      end

      @spec apply(t, any) :: application_result
      def apply(%__MODULE__{compiled: compiled}, value) do
        compiled.(value)
      end

      @spec new(meta_data) :: t
      defp new(meta) do
        %__MODULE__{compiled: nil, meta: meta}
      end
    end
  end
end
