defmodule Validation.Result do
  @moduledoc """
  The result of a validation. It contains the final data and errors.
  """

  defstruct [
    data: %{},
    errors: %{}
  ]

  def put_error(%__MODULE__{} = result, key, message) do
    %{result | errors: Map.update(result.errors, key, [message], fn messages -> [message | messages] end)}
  end
end
