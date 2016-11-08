defmodule Validation.PredicateTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate

  test "a simple empty? predicate" do
    name = "empty?"
    fun = fn value -> value in [nil, ""] end
    message = "must be empty"

    predicate = Predicate.build(name, fun, message)

    assert predicate.name == name
    assert predicate.fun == fun
    assert predicate.message == message

    compiled = Predicate.compile(predicate)

    assert compiled.("") == :ok
    assert compiled.("foo") == {:error, "must be empty"}
  end
end
