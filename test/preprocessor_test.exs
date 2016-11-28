defmodule Validation.PreprocessorTest do
  use ExUnit.Case, async: true

  alias Validation.Preprocessor

  test "building a preprocessor manually" do
    fun = fn params ->
      params
      |> Enum.map(fn {key, value} -> {key, value |> String.upcase} end)
      |> Enum.into(%{})
    end

    preprocessor = Preprocessor.build(fun, name: "My preprocessor")
    assert preprocessor.meta == [name: "My preprocessor"]

    params = %{name: "John"}
    processed = Preprocessor.apply(preprocessor, params)

    assert processed == %{name: "JOHN"}
  end
end
