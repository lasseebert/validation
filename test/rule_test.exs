defmodule Validation.RuleTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Result
  alias Validation.Rule

  def apply_rule(rule, data) do
    Rule.apply(rule, %Result{data: data})
  end

  test "building a simple custom rule" do
    val = fn result ->
      if result.data[:name] do
        result
      else
        Result.put_error(result, :name, "must be filled")
      end
    end

    rule   = Rule.build(val, name: ["name must be filled"])

    assert %{errors: %{}} = apply_rule(rule,  %{name: "Me"})
    assert %{errors: %{name: ["must be filled"]}} = apply_rule(rule, %{})
  end

  test "built-in value rule" do
    filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
    rule    = Rule.built_in("value", :name, filled?)

    assert %{errors: %{}} = apply_rule(rule, %{name: "Me"})
    assert %{errors: %{name: ["must be filled"]}} = apply_rule(rule, %{})
  end

  test "built_in required rule" do
    rule = Rule.built_in("required", :name)

    assert %{errors: %{}} = apply_rule(rule, %{name: "Me"})
    assert %{errors: %{name: ["is missing"]}} = apply_rule(rule, %{})
  end
end
