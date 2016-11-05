defmodule ValidationTest do
  @moduledoc """
  Tests for higher layer usages of Validation.
  Edge case tests should be in the tests for the respective modules
  """

  use ExUnit.Case, async: true

  alias Validation.Result
  require Validation

  def name_email_schema do
    Validation.schema do
      optional(:name, filled? and type?(:string))
      required(:email, filled? and type?(:string) and match?(~r/@/))
    end
  end

  test "basic usage with valid params" do
    params = %{
      name: "Chuck Norris",
      email: "gmail@chucknorris.com"
    }

    result = Validation.result(params, name_email_schema)

    assert result.errors == %{}
    assert result.data == %{name: "Chuck Norris", email: "gmail@chucknorris.com"}
    assert Result.valid?(result) == true
  end

  test "basic usage with invalid params" do
    params = %{
      name: "Derp",
      email: "Derp"
    }

    result = Validation.result(params, name_email_schema)

    assert result.errors == %{email: ["is invalid"]}
    assert result.data == %{name: "Derp", email: "Derp"}
    assert Result.valid?(result) == false
  end

  test "whitelisting params" do
    params = %{
      name: "Chuck Norris",
      email: "gmail@chucknorris.com",
      other: "thing"
    }

    result = Validation.result(params, name_email_schema)

    assert result.errors == %{}
    assert result.data == %{name: "Chuck Norris", email: "gmail@chucknorris.com"}
  end

  test "missing required params" do
    params = %{
      name: "Derp With No Email"
    }

    result = Validation.result(params, name_email_schema)

    assert result.errors == %{email: ["is missing"]}
    assert result.data == %{name: "Derp With No Email"}
  end

  test "missing optional params" do
    params = %{
      email: "noname@example.com"
    }

    result = Validation.result(params, name_email_schema)

    assert result.errors == %{}
    assert result.data == %{email: "noname@example.com"}
  end
end
