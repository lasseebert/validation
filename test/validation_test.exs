defmodule ValidationTest do
  @moduledoc """
  Tests for higher layer usages of Validation.
  Edge case tests should be in the tests for the respective modules
  """

  use ExUnit.Case, async: true
  require Validation

  def name_email_schema do
    Validation.schema do
      optional(:name, filled? and string?)
      required(:email, filled? and string? and match?(~r/@/))
    end
  end

  @tag :skip
  test "basic usage with valid params" do
    params = %{
      "name" => "Chuck Norris",
      "email" => "gmail@chucknorris.com"
    }

    result = Validation.result(params, name_email_schema)

    assert result.errors == %{}
    assert result.valid? == true
    assert result.data == %{name: "Chuck Norris", email: "gmail@chucknorris.com"}
  end

  @tag :skip
  test "basic usage with invalid params"
  @tag :skip
  test "whitelisting params"
  @tag :skip
  test "optional params"
end
