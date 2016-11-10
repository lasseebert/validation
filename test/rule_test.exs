defmodule Validation.RuleTest do
  use ExUnit.Case, async: true

  alias Validation.BasicPredicate
  alias Validation.Result
  alias Validation.Rule
  alias Validation.Validator

  test "building a simple custom rule" do
    fun = fn result ->
      if result.data[:name] do
        result
      else
        Result.put_error(result, :name, "must be filled")
      end
    end

    rule = Rule.build(fun, name: ["name must be filled"])

    compiled = Validator.compile(rule)

    result = %Result{data: %{name: "Me"}} |> compiled.()
    assert result.errors == %{}

    result = %Result{data: %{}} |> compiled.()
    assert result.errors == %{name: ["must be filled"]}
  end

  test "building a value rule" do
    filled? = BasicPredicate.build(fn value -> !(value in ["", nil]) end, "must be filled", [name: "filled?"])
    rule = Rule.build_value_rule(:name, filled?)

    compiled = Validator.compile(rule)

    result = %Result{data: %{name: "Me"}} |> compiled.()
    assert result.errors == %{}

    result = %Result{data: %{}} |> compiled.()
    assert result.errors == %{name: ["must be filled"]}
  end

  test "building a required key rule" do
    rule = Rule.build_required_key(:name)

    compiled = Validator.compile(rule)

    result = %Result{data: %{name: "Me"}} |> compiled.()
    assert result.errors == %{}

    result = %Result{data: %{}} |> compiled.()
    assert result.errors == %{name: ["is missing"]}
  end
end
