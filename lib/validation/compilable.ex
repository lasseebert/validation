defprotocol Validation.Compilable do
  def compile(compilable)
end

defimpl Validation.Compilable, for: Any do
  def compile(_), do: raise("Not compilable")
end
