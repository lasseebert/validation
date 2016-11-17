defmodule Validation.SchemaTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Rule
  alias Validation.Schema

  def simple_schema do
    Schema.build([Rule.built_in("value", :name, Predicate.built_in("filled?"))])
  end

  test "simple schema has metadata" do
    schema = simple_schema

    assert [%Rule{}] = schema.meta[:rules]
  end

  test "simple schema against invalid data" do
    params = %{name: ""}
    result = simple_schema.val.(params)

    assert result.valid? == false
    assert result.data == %{name: ""}
    assert result.errors == %{name: ["must be filled"]}
  end

  test "simple schema against valid data" do
    params = %{name: "John"}
    result = simple_schema.val.(params)

    assert result.valid? == true
    assert result.data == %{name: "John"}
    assert result.errors == %{}
  end
end