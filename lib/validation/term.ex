defmodule Validation.Term do
  @moduledoc """
  A term is the building block of the validation algebra.
  It can either be primitive `Validation.Term.Primitive` or
  `Validation.Term.Compound`.

  When the algebra is compiled a tree of is created
  where leaf nodes are primitive terms and branch nodes
  are compound terms.
  """

  defmacro __using__(_opts) do
    quote do
      import Validation.Term
      alias Validation.Compilable

      defstruct compiled: nil, meta: %{}

      @type t           :: %__MODULE__{compiled: compilation, meta: %{}}
      @type meta_data   :: Keyword.t
      @type compilation :: ((any) -> evaluation_result)

      @callback new(map)          :: t
      @callback compile_term(map) :: {:ok, t} | {:error, String.t}
      @callback evaluate(t, any)  :: any
      @optional_callbacks new: 1, evaluate: 2, compile_term: 1

      @spec apply(t, any) :: evaluation_result
      def apply(%__MODULE__{compiled: compilation}, value) do
        compilation.(value)
      end

      @spec new(map) :: t
      def new(configuration) do
        %__MODULE__{meta: configuration}
      end

      @type configuration :: Keyword.t
      @spec build_term(configuration) :: t | no_return
      def build_term(config \\ []) do
        {:ok, term} = config
                        |> Enum.into(%{})
                        |> compile_term

        term
      end

      @spec compile_term(map) :: :ok | {:error, String.t}
      defp compile_term(configuration) do
        term = new(configuration)

        with {:ok, compiled} <- Compilable.compile(term) do
          {:ok, %{term | compiled: compiled}}
        end
      end
    end
  end
end

defmodule Validation.Term.Primitive do
  @moduledoc """
  A primitive encapsulates invariants on the data that is to be validated.
  When it is evaluated it either returns `:ok` or an error `{:error, String.t}`.

  You can create your own primitive terms by implementing `using` this module
  and optionally implementing `Validation.Compilable` for your configuration.
  """

  defmacro __using__(_opts) do
    quote do
      use Validation.Term

      @type evaluation_result :: :ok | {:error, String.t}
    end
  end
end

defmodule Validation.Term.Compound do
  @moduledoc """
  A compound term is a term that orchestrates other
  compound or primitive terms. If it is evaluated it
  returns a `Validation.Result`.
  """

  defmacro __using__(_opts) do
    quote do
      use Validation.Term
      alias Validation.Result

      @type evaluation_result :: Result.t
    end
  end
end
