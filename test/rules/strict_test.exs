defmodule Validation.Rules.StrictTest do
  use ExUnit.Case, async: true

  alias Validation.Rule
  alias Validation.Rules

  test "building a strict rule strict rule" do
    strict_rule = Rules.Strict.build([:name, :email])

    assert strict_rule.meta[:type] == "strict"
    assert strict_rule.meta[:keys] == [:name, :email]

    errors = Rule.apply(strict_rule, %{name: "Me", email: "me@example.com"})
    assert errors == %{}

    errors = Rule.apply(strict_rule, %{name: "Me", email: "me@example.com", age: 42})
    assert errors == %{age: ["is not an expected key"]}
  end
end
