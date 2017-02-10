defmodule Validation.DSLTest do
  use ExUnit.Case, async: true

  require Validation
  alias Validation.Schema

  test "very simple schema" do
    schema = Validation.schema do
      required(:name, filled?)
    end

    params = %{name: "John"}
    result = Schema.apply(schema, params)
    assert result.valid?

    params = %{first_name: "John"}
    result = Schema.apply(schema, params)
    refute result.valid?
  end

  @tag :skip
  test "multiple fields"

  @tag :skip
  test "no predicate"

  @tag :skip
  test "optional field"

  @tag :skip
  test "nested schema"

  @tag :skip
  test "custom predicate"

  @tag :skip
  test "custom predicate combined with a built-in one"

  @tag :skip
  test "custom rule"

  @tag :skip
  test "white list"

  @tag :skip
  test "strict"
end
