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

  test "combining preprocessors" do
    upcaser = Preprocessor.build(fn params ->
      params |>
      Enum.map(fn {key, value} -> {key, value |> String.upcase} end)
      |> Enum.into(%{})
    end, name: "upcaser")
    x_remover = Preprocessor.build(fn params ->
      params
      |> Enum.reject(fn {key, _value} -> key |> inspect |> String.match?(~r/x/) end)
      |> Enum.into(%{})
    end, name: "x_remover")

    combined = Preprocessor.combine([upcaser, x_remover])

    assert combined.meta[:preprocessors] |> Enum.map(&(&1.meta)) == [[name: "upcaser"], [name: "x_remover"]]

    params = %{
      name: "John",
      name_x: "Wayne"
    }
    processed = Preprocessor.apply(combined, params)

    assert processed == %{name: "JOHN"}
  end

  test "identity preprocessor" do
    identity = Preprocessor.identity
    params = %{name: "John"}

    assert Preprocessor.apply(identity, params) == params
  end

  test "whitelist preprocessor" do
    whitelister = Preprocessor.whitelist([:name, :email])

    params = %{
      name: "John",
      email: "john@wayne.com",
      age: 45
    }

    updated_params = Preprocessor.apply(whitelister, params)

    assert updated_params == %{
      name: "John",
      email: "john@wayne.com"
    }
  end
end
