defmodule Validation.Term do
  defmacro __using__(_opts) do
    quote do
      @type t            :: %__MODULE__{val: compiled_fun, meta: meta_data}
      @typep compiled_fun :: ((any) -> Result.t)
      @typep meta_data    :: Keyword.t

      defstruct val: nil, meta: %{}

      def apply(%__MODULE__{val: val}, value) do
        val.(value)
      end

      def compile(meta \\ []) do
        term = meta
        |> Enum.into(%{})
        |> new

        compiled = Validation.Compilable.compile(term)

        %{term | val: compiled}
      end

      @spec new(meta_data) :: Validation.Compilable.t
      defp new(meta) do
        %__MODULE__{val: nil, meta: meta}
      end
    end
  end
end
