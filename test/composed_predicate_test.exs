defmodule Validation.ComposedPredicateTest do
  use ExUnit.Case, async: true

  alias Validation.BasicPredicate
  alias Validation.ComposedPredicate
  alias Validation.Validator

  test "building an and-predicate manually" do
    filled? = BasicPredicate.build(fn value -> !(value in ["", nil]) end, "must be filled", [name: "filled?"])
    string? = BasicPredicate.build(&is_binary/1, "must be a string", [name: "string?"])

    compiler = fn [left, right] ->
      left_compiled = Validator.compile(left)
      right_compiled = Validator.compile(right)

      fn value ->
        with :ok <- left_compiled.(value) do
          right_compiled.(value)
        end
      end
    end
    composed = ComposedPredicate.build([filled?, string?], compiler)

    compiled = Validator.compile(composed)

    assert compiled.("") == {:error, "must be filled"}
    assert compiled.(42) == {:error, "must be a string"}
    assert compiled.("foo") == :ok
  end
end
