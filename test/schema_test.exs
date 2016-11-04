defmodule Validation.SchemaTest do
  use ExUnit.Case, async: true

  alias Validation.Schema
  require Schema

  test "building a simple schema" do
    schema = Schema.define do
      optional(:name, filled and string)
    end

    rules = schema.rules

    assert rules.name.field == :name
    assert rules.name.key_rule == :optional
    assert rules.name.value_predicates == {
      :and,
      {:filled, []},
      {:string, []}
    }
  end

  test "building a schema with multiple rules" do
    schema = Schema.define do
      optional(:first_name, filled and string)
      required(:last_name, filled and string)
    end

    assert schema.rules.first_name
    assert schema.rules.last_name
  end

  @tag :skip
  test "using predicate functions with parameters" do
    schema = Schema.define do
      required(:email, match(~r/@/))
    end

    assert schema.rules.email.field == :email
    assert schema.rules.email.key_rule == :required
    assert schema.rules.email.value_predicates == {:match, [~r/@/]}
  end
end
