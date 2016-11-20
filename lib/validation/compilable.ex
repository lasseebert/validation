defprotocol Validation.Compilable do
  @fallback_to_any true
  @type result       :: {:ok, any} | {:error, String.t}
  @spec compile(any) :: result

  def compile(compilable)
end

defimpl Validation.Compilable, for: Any do
  def compile(_), do: {:error, "Can not compile #{__MODULE__}"}
end
