defmodule Validation.RuleTest do
  use ExUnit.Case, async: true

  alias Validation.Rule

  test "building a simple custom rule" do
    val = fn params ->
      if params[:name] do
        %{}
      else
        %{name: ["must be filled"]}
      end
    end

    rule = Rule.build(val, name: "name must be filled")

    errors = Rule.apply(rule, %{name: "Me"})
    assert errors == %{}

    errors = Rule.apply(rule, %{})
    assert errors == %{name: ["must be filled"]}
  end
end
