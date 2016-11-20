defprotocol Validation.Compilable do
  @type result       :: {:ok, any} | {:error, String.t}
  @spec compile(any) :: result
  def compile(compilable)
end
