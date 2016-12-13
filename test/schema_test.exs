defmodule Validation.SchemaTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Preprocessor
  alias Validation.Rule
  alias Validation.Schema

  def simple_schema do
    Schema.build([Rule.BuiltIn.value(:name, Predicate.built_in("filled?"))])
  end

  test "simple schema has metadata" do
    schema = simple_schema

    assert [%Rule{}] = schema.meta[:rules]
  end

  test "simple schema against invalid data" do
    params = %{name: ""}
    result = Schema.apply(simple_schema, params)

    assert result.valid? == false
    assert result.data == %{name: ""}
    assert result.errors == %{name: ["must be filled"]}
  end

  test "simple schema against valid data" do
    params = %{name: "John"}
    result = Schema.apply(simple_schema, params)

    assert result.valid? == true
    assert result.data == %{name: "John"}
    assert result.errors == %{}
  end

  test "schema with preprocessor" do
    upcaser = Preprocessor.build(fn params ->
      params |>
      Enum.map(fn {key, value} -> {key, value |> String.upcase} end)
      |> Enum.into(%{})
    end)

    schema = Schema.build(
      [Rule.BuiltIn.value(:name, Predicate.built_in("filled?"))],
      upcaser
    )

    params = %{name: "John"}
    result = Schema.apply(schema, params)

    assert result.valid? == true
    assert result.data == %{name: "JOHN"}
    assert result.errors == %{}

    assert schema.meta[:preprocessor] == upcaser
  end
end
