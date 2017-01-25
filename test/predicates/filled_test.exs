defmodule Validation.Predicates.FilledTest do
  use ExUnit.Case, async: true

  alias Validation.Predicates.Filled

  test "building from two basic predicates" do
    filled? = Filled.build()

    assert filled?.meta[:name] == "filled?"
    assert filled?.meta[:type] == "basic"

    assert filled?.val.("something") == :ok
    assert filled?.val.(42) == :ok
    assert filled?.val.(nil) == {:error, "must be filled"}
    assert filled?.val.("") == {:error, "must be filled"}
    assert filled?.val.([]) == {:error, "must be filled"}
    assert filled?.val.(%{}) == {:error, "must be filled"}
  end
end
