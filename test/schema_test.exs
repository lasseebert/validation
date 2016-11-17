defmodule Validation.SchemaTest do
  use ExUnit.Case, async: true

  alias Validation.Predicate
  alias Validation.Rule
  alias Validation.Schema

  test "using a simple schema" do
    schema = Schema.build([Rule.built_in("value", :name, Predicate.built_in("filled?"))])

    assert schema.meta[:rules] |> length == 1

    params = %{name: ""}
    result = schema.val.(params)

    assert result.valid? == false
    assert result.data == %{name: ""}
    assert result.errors == %{name: ["must be filled"]}
  end
end
