defmodule Validation.Result do
  @moduledoc """
  The result of a validation. It contains the final data and errors.
  """

  @type t :: %__MODULE__{ data: Map.t, errors: Map.t, valid?: Bool.t }

  defstruct [
    data: %{},
    errors: %{},
    valid?: true
  ]

  @spec put_error(t, Any.t, String.t) :: t
  def put_error(%__MODULE__{} = result, key, message) do
    %{result |
      errors: Map.update(result.errors, key, [message], fn messages -> [message | messages] end),
      valid?: false
    }
  end
end
