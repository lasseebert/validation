defmodule Validation.Term do
  defmacro __using__(_opts) do
    quote do
      @type t            :: %__MODULE__{compiled: compiled_fun, meta: meta_data}
      @typep compiled_fun :: ((any) -> application_result)
      @typep meta_data    :: Keyword.t

      defstruct compiled: nil, meta: %{}

      @spec apply(t, any) :: application_result
      def apply(%__MODULE__{compiled: compiled}, value) do
        compiled.(value)
      end

      def compile(meta \\ []) do
        term = meta
                |> Enum.into(%{})
                |> new

        compiled = Validation.Compilable.compile(term)

        %{term | compiled: compiled}
      end

      @spec new(meta_data) :: Validation.Compilable.t
      defp new(meta) do
        %__MODULE__{compiled: nil, meta: meta}
      end
    end
  end
end
