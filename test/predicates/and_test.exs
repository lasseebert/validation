defmodule Validation.Predicates.AndTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Predicates.And

  test "building from two basic predicates" do
    filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
    string? = Predicate.build_basic(&is_binary/1, "must be a string", "string?")

    composed = And.build(filled?, string?)

    assert composed.val.("") == {:error, "must be filled"}
    assert composed.val.(42) == {:error, "must be a string"}
    assert composed.val.("foo") == :ok
  end
end
