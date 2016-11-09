defmodule Validation.BasicPredicateTest do
  use ExUnit.Case, async: true

  alias Validation.BasicPredicate

  test "a simple empty? predicate" do
    fun = fn value -> value in [nil, ""] end
    message = "must be empty"
    name = "empty?"

    predicate = BasicPredicate.build(fun, message, [name: name])

    assert predicate.fun == fun
    assert predicate.message == message
    assert predicate.meta |> Keyword.get(:name) == name

    compiled = BasicPredicate.compile(predicate)

    assert compiled.("") == :ok
    assert compiled.("foo") == {:error, "must be empty"}
  end
end
