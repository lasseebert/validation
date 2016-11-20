defmodule Validation.Term do
  @moduledoc """
  A term is the building block of the validation algebra.
  It can either be primitive `Validation.Term.Primitive` or
  `Validation.Term.Compound`.

  When the algebra is compiled a tree of is created
  where leaf nodes are primitive terms and branch nodes
  are compound terms.
  """

  defmodule Primitive do
    @moduledoc """
    A primitive encapsulates invariants on the data that is to be validated.
    When it is evaluated it either returns `:ok` or an error `{:error, String.t}`.

    You can create your own primitive terms by implementing `using` this module
    and implementing `Validation.Compilable` for your configuration.
    """

    @type evaluation_result :: :ok | {:error, String.t}

    defmacro __using__(_opts) do
      quote do
        use Validation.Term

        def succeed,       do: :ok
        def fail(message), do: {:error, message}
      end
    end
  end

  defmodule Compound do
    @moduledoc """
    A compound term is a term that orchestrates other
    compound or primitive terms. If it is evaluated it
    returns a `Validation.Result`.
    """

    alias Validation.Result

    @type evaluation_result :: Result.t

    defmacro __using__(_opts) do
      quote do
        use Validation.Term
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      alias  Validation.Compilable
      alias  Validation.Term.{Primitive, Compound}

      defstruct compiled: nil, meta: %{}

      @type t           :: %__MODULE__{compiled: compilation, meta: %{}}
      @type meta_data   :: Keyword.t
      @type compilation :: ((any) -> Compound.evaluation_result | Primitive.evaluation_result)

      @callback new(map)          :: t
      @callback compile_term(map) :: {:ok, t} | {:error, String.t}
      @optional_callbacks new: 1, compile_term: 1

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

  @type evaluation_result  :: Primitive.evaluation_result | Compound.evaluation_result
  @spec evaluate(any, any) :: evaluation_result | no_return
  def evaluate(%{compiled: compiled}, value) when is_function(compiled) do
    compiled.(value)
  end

  def evaluate(_, _) do
    raise("Term can not be evaluated")
  end
end
