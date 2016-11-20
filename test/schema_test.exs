defmodule Validation.SchemaTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Rule
  alias Validation.Schema
  alias Validation.Term

  def simple_schema do
    Schema.build([Rule.built_in("value", :name, Predicate.built_in("filled?"))])
  end

  def nested_schema do
    Schema.build([
      Rule.built_in("required", :id),
      Rule.built_in("schema", :user, simple_schema)
    ])
  end

  describe "nested schema" do
    test "has metadata" do
      schema = nested_schema

      assert [%Rule{}, %Rule{}] = schema.meta[:rules]
    end

    test "against invalid data" do
      params = %{user: %{ name: "" }}
      result = Term.evaluate(nested_schema, params)

      refute result.valid?
      assert result.data   == %{user: %{name: ""}}
      assert result.errors == %{id: ["is missing"], user: [%{name: ["must be filled"]}]}
    end

    test "against invalid nested data" do
      params = %{id: 1, user: %{ name: "" }}
      result = Term.evaluate(nested_schema, params)

      refute result.valid?
      assert result.data   == params
      assert result.errors == %{user: [%{name: ["must be filled"]}]}
    end

    test "against valid data" do
      params = %{id: 1, user: %{ name: "Alice" }}
      result = Term.evaluate(nested_schema, params)

      assert result.valid?
      assert result.data == params
      assert result.errors == %{}
    end
  end

  describe "simple schema" do
    test "has metadata" do
      schema = simple_schema

      assert [%Rule{}] = schema.meta[:rules]
    end

    test "against invalid data" do
      params = %{name: ""}
      result = Term.evaluate(simple_schema, params)

      refute result.valid?
      assert result.data == params
      assert result.errors == %{name: ["must be filled"]}
    end

    test "simple schema against valid data" do
      params = %{name: "John"}
      result = Term.evaluate(simple_schema, params)

      assert result.valid?
      assert result.data == params
      assert result.errors == %{}
    end
  end
end
