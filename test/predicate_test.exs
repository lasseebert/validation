defmodule Validation.PredicateTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate

  test "a simple empty? predicate build with basic" do
    fun = fn value -> value in [nil, ""] end
    message = "must be empty"
    name = "empty?"

    predicate = Predicate.build_basic(fun, message, name)

    assert predicate.meta[:message] == message
    assert predicate.meta[:name] == name
    assert predicate.meta[:type] == "basic"

    assert predicate.val.("") == :ok
    assert predicate.val.("foo") == {:error, "must be empty"}
  end

  test "building a composed and-predicate manually" do
    filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
    string? = Predicate.build_basic(&is_binary/1, "must be a string", "string?")

    composer = fn [left, right] ->
      fn value ->
        with :ok <- left.val.(value) do
          right.val.(value)
        end
      end
    end
    composed = Predicate.build_composed([filled?, string?], composer, "and")

    assert composed.meta[:name] == "and"
    assert composed.meta[:type] == "composed"
    assert composed.meta[:predicates] == [filled?, string?]

    assert composed.val.("") == {:error, "must be filled"}
    assert composed.val.(42) == {:error, "must be a string"}
    assert composed.val.("foo") == :ok
  end

  test "building an and-predicate with the built-in helper function" do
    filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
    string? = Predicate.build_basic(&is_binary/1, "must be a string", "string?")

    composed = Predicate.build_and(filled?, string?)

    assert composed.val.("") == {:error, "must be filled"}
    assert composed.val.(42) == {:error, "must be a string"}
    assert composed.val.("foo") == :ok
  end
end
