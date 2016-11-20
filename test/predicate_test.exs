defmodule Validation.PredicateTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Term

  test "a simple empty? predicate build with basic" do
    fun = fn value -> value in [nil, ""] end
    message = "must be empty"
    name = "empty?"

    predicate = Predicate.build_basic(fun, message, name)

    assert predicate.meta[:message] == message
    assert predicate.meta[:name] == name
    assert predicate.meta[:type] == "basic"

    assert Term.evaluate(predicate, "") == :ok
    assert Term.evaluate(predicate, "foo") == {:error, "must be empty"}
  end

  test "building a composed and-predicate manually" do
    filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
    string? = Predicate.build_basic(&is_binary/1, "must be a string", "string?")

    composer = fn [left, right] ->
      fn value ->
        with :ok <- left.compiled.(value) do
          right.compiled.(value)
        end
      end
    end
    composed = Predicate.build_composed([filled?, string?], composer, "and")

    assert composed.meta[:name] == "and"
    assert composed.meta[:type] == "composed"
    assert composed.meta[:predicates] == [filled?, string?]

    assert Term.evaluate(composed, "") == {:error, "must be filled"}
    assert Term.evaluate(composed, 42) == {:error, "must be a string"}
    assert Term.evaluate(composed, "foo") == :ok
  end

  describe "built_in" do
    test "and" do
      filled? = Predicate.build_basic(fn value -> !(value in ["", nil]) end, "must be filled", "filled?")
      string? = Predicate.build_basic(&is_binary/1, "must be a string", "string?")

      composed = Predicate.built_in("and", filled?, string?)

      assert Term.evaluate(composed, "") == {:error, "must be filled"}
      assert Term.evaluate(composed, 42) == {:error, "must be a string"}
      assert Term.evaluate(composed, "foo") == :ok
    end

    test "filled?" do
      filled? = Predicate.built_in("filled?")

      assert filled?.meta[:name] == "filled?"
      assert filled?.meta[:type] == "basic"

      assert Term.evaluate(filled?, "something") == :ok
      assert Term.evaluate(filled?, 42) == :ok
      assert Term.evaluate(filled?, nil) == {:error, "must be filled"}
      assert Term.evaluate(filled?, "") == {:error, "must be filled"}
      assert Term.evaluate(filled?, []) == {:error, "must be filled"}
      assert Term.evaluate(filled?, %{}) == {:error, "must be filled"}
    end
  end
end
