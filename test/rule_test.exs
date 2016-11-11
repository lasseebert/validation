defmodule Validation.RuleTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Result
  alias Validation.Rule

  test "building a simple custom rule" do
    val = fn result ->
      if result.data[:name] do
        result
      else
        Result.put_error(result, :name, "must be filled")
      end
    end

    rule = Rule.build(val, name: ["name must be filled"])

    result = %Result{data: %{name: "Me"}} |> rule.val.()
    assert result.errors == %{}

    result = %Result{data: %{}} |> rule.val.()
    assert result.errors == %{name: ["must be filled"]}
  end

  test "building a value rule" do
    filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
    rule = Rule.build_value_rule(:name, filled?)

    result = %Result{data: %{name: "Me"}} |> rule.val.()
    assert result.errors == %{}

    result = %Result{data: %{}} |> rule.val.()
    assert result.errors == %{name: ["must be filled"]}
  end

  test "building a required key rule" do
    rule = Rule.build_required_key(:name)

    result = %Result{data: %{name: "Me"}} |> rule.val.()
    assert result.errors == %{}

    result = %Result{data: %{}} |> rule.val.()
    assert result.errors == %{name: ["is missing"]}
  end
end
