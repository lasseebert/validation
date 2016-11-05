defmodule Validation.SchemaTest do
  use ExUnit.Case, async: true

  alias Validation.Schema
  require Schema

  test "building a simple schema" do
    schema = Schema.define do
      optional(:name, filled and string)
    end

    assert schema.rules |> length == 1

    rule = schema.rules |> hd
    assert rule.field == :name
    assert rule.key_rule == :optional
    assert rule.value_predicates == {
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

    assert schema.rules |> length == 2

    [rule_1, rule_2] = schema.rules
    assert rule_1.field == :first_name
    assert rule_2.field == :last_name
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
