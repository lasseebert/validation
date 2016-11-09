defprotocol Validation.Validator do
  @moduledoc """
  Protocol for all parts of a schema.
  """

  @doc """
  Compiles the given validator. The result of compilation is a function.
  """
  def compile(validator)
end
