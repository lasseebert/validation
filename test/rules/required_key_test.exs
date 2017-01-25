defmodule Validation.Rules.RequiredKeyTest do
  use ExUnit.Case, async: true

  alias Validation.Rule
  alias Validation.Rules

  test "building a required key rule" do
    rule = Rules.RequiredKey.build(:name)

    errors = Rule.apply(rule, %{name: "Me"})
    assert errors == %{}

    errors = Rule.apply(rule, %{})
    assert errors == %{name: ["is missing"]}
  end
end
