defmodule Validation.RuleTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Rule

  test "building a simple custom rule" do
    val = fn params ->
      if params[:name] do
        %{}
      else
        %{name: ["must be filled"]}
      end
    end

    rule = Rule.build(val, name: ["name must be filled"])

    errors = Rule.apply(rule, %{name: "Me"})
    assert errors == %{}

    errors = Rule.apply(rule, %{})
    assert errors == %{name: ["must be filled"]}
  end

  describe "built-in rules" do
    test "value rule" do
      filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
      rule = Rule.BuiltIn.value(:name, filled?)

      errors = Rule.apply(rule, %{name: "Me"})
      assert errors == %{}

      errors = Rule.apply(rule, %{})
      assert errors == %{name: ["must be filled"]}
    end

    test "built-in required rule" do
      rule = Rule.BuiltIn.required_key(:name)

      errors = Rule.apply(rule, %{name: "Me"})
      assert errors == %{}

      errors = Rule.apply(rule, %{})
      assert errors == %{name: ["is missing"]}
    end

    test "built-in strict rule" do
      strict_rule = Rule.BuiltIn.strict([:name, :email])

      assert strict_rule.meta[:type] == "strict"
      assert strict_rule.meta[:keys] == [:name, :email]

      errors = Rule.apply(strict_rule, %{name: "Me", email: "me@example.com"})
      assert errors == %{}

      errors = Rule.apply(strict_rule, %{name: "Me", email: "me@example.com", age: 42})
      assert errors == %{age: ["is not an expected key"]}
    end
  end
end
