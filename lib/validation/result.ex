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

  @spec merge(t, t) :: t
  def merge(lhs, rhs) do
    if lhs.valid? && rhs.valid? do
      %__MODULE__{valid?: true, errors: %{}, data: Map.merge(lhs.data, rhs.data)}
    else
      %__MODULE__{valid?: false, errors: Map.merge(lhs.errors, rhs.errors), data: Map.merge(lhs.data, rhs.data)}
    end
  end
end
