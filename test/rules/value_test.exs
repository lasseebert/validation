defmodule Validation.Rules.ValueTest do
  use ExUnit.Case, async: true

  alias Validation.Predicates
  alias Validation.Rule
  alias Validation.Rules

  test "building a value rule" do
    filled? = Predicates.Filled.build()
    rule = Rules.Value.build(:name, filled?)

    errors = Rule.apply(rule, %{name: "Me"})
    assert errors == %{}

    errors = Rule.apply(rule, %{})
    assert errors == %{name: ["must be filled"]}
  end
end
