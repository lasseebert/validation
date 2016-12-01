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

  test "built-in value rule" do
    filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
    rule = Rule.built_in("value", :name, filled?)

    errors = Rule.apply(rule, %{name: "Me"})
    assert errors == %{}

    errors = Rule.apply(rule, %{})
    assert errors == %{name: ["must be filled"]}
  end

  test "built_in required rule" do
    rule = Rule.built_in("required", :name)

    errors = Rule.apply(rule, %{name: "Me"})
    assert errors == %{}

    errors = Rule.apply(rule, %{})
    assert errors == %{name: ["is missing"]}
  end
end
