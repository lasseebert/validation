defmodule Validation.Result do
  @moduledoc """
  The result of a validation. It contains the final data and errors.
  """

  @type t :: %__MODULE__{data: map, errors: map, valid?: boolean}

  defstruct [
    data: %{},
    errors: %{},
    valid?: true
  ]

  @spec put_error(t, any, String.t) :: t
  def put_error(%__MODULE__{} = result, key, message) do
    %{result |
      errors: Map.update(result.errors, key, [message], fn messages -> [message | messages] end),
      valid?: false
    }
  end

  @spec merge_errors(t, map) :: t
  @doc """
  Merges the given errors with the errors in the result.
  Returns an updated result
  """
  def merge_errors(%__MODULE__{} = result, errors) do
    updated_errors = Map.merge(result.errors, errors, fn _key, v1, v2 ->
      Enum.uniq(v1 ++ v2)
    end)

    %{result |
      errors: updated_errors,
      valid?: !Enum.any?(updated_errors)
    }
  end
end
