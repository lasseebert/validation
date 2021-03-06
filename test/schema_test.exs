defmodule Validation.SchemaTest do
  use ExUnit.Case, async: true

  alias Validation.Predicates
  alias Validation.Preprocessor
  alias Validation.Rule
  alias Validation.Rules
  alias Validation.Schema

  def simple_schema do
    Schema.build([Rules.Value.build(:name, Predicates.Filled.build())], %{})
  end

  test "simple schema has metadata" do
    schema = simple_schema()

    assert [%Rule{}] = schema.meta[:rules]
  end

  test "simple schema against invalid data" do
    params = %{name: ""}
    result = Schema.apply(simple_schema(), params)

    assert result.valid? == false
    assert result.data == %{name: ""}
    assert result.errors == %{name: ["must be filled"]}
  end

  test "simple schema against valid data" do
    params = %{name: "John"}
    result = Schema.apply(simple_schema(), params)

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
      [Rules.Value.build(:name, Predicates.Filled.build())],
      %{},
      preprocessor: upcaser
    )

    params = %{name: "John"}
    result = Schema.apply(schema, params)

    assert result.valid? == true
    assert result.data == %{name: "JOHN"}
    assert result.errors == %{}

    assert schema.meta[:preprocessor] == upcaser
  end

  test "strict schema" do
    rules = [
      Rules.Value.build(:name, Predicates.Filled.build()),
      Rules.Value.build(:email, Predicates.Filled.build()),
    ]
    schema = Schema.build(rules, %{}, strict: true)

    assert schema.meta[:rules] |> length == 3
    assert schema.meta[:rules] |> hd |> Map.get(:meta) |> Keyword.get(:type) == "strict"

    params = %{name: "me", email: "me@example.com"}
    result = Schema.apply(schema, params)
    assert result.valid?

    params = %{name: "me", email: "me@example.com", age: 42}
    result = Schema.apply(schema, params)
    refute result.valid?
  end

  test "whitelist schema" do
    rules = [
      Rules.Value.build(:name, Predicates.Filled.build()),
      Rules.Value.build(:email, Predicates.Filled.build()),
    ]
    schema = Schema.build(rules, %{}, whitelist: true)

    assert schema.meta[:preprocessor].meta[:type] == "combined"

    params = %{name: "me", email: "me@example.com", age: 42}
    result = Schema.apply(schema, params)
    assert result.data == %{name: "me", email: "me@example.com"}
  end

  test "nested schema" do
    rules = [Rules.Value.build(:name, Predicates.Filled.build())]
    nested_schema = Schema.build(rules, %{})
    schema = Schema.build([], %{user: nested_schema})

    params = %{user: %{name: ""}}
    result = Schema.apply(schema, params)
    assert result.data == %{user: %{name: ""}}
    assert result.valid? == false
    assert result.errors == %{user: %{name: ["must be filled"]}}
  end

  test "deeply nested schema" do
    rules = [Rules.Value.build(:name, Predicates.Filled.build())]
    user_schema = Schema.build(rules, %{})
    attrs_schema = Schema.build([], %{user: user_schema})
    schema = Schema.build([], %{attrs: attrs_schema})

    params = %{attrs: %{user: %{name: ""}}}
    result = Schema.apply(schema, params)
    assert result.data == %{attrs: %{user: %{name: ""}}}
    assert result.valid? == false
    assert result.errors == %{attrs: %{user: %{name: ["must be filled"]}}}
  end

  test "nested schema when nested value is not a map" do
    rules = [Rules.Value.build(:name, Predicates.Filled.build())]
    nested_schema = Schema.build(rules, %{})
    schema = Schema.build([], %{user: nested_schema})

    params = %{user: "Not a map"}
    result = Schema.apply(schema, params)
    assert result.data == %{user: "Not a map"}
    assert result.valid? == false
    assert result.errors == %{user: ["is invalid"]}
  end
end
