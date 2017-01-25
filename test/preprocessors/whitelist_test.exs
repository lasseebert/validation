defmodule Validation.Preprocessors.WhitelistTest do
  use ExUnit.Case, async: true

  alias Validation.Preprocessor
  alias Validation.Preprocessors

  test "whitelist preprocessor" do
    whitelister = Preprocessors.Whitelist.build([:name, :email])

    params = %{
      name: "John",
      email: "john@wayne.com",
      age: 45
    }

    updated_params = Preprocessor.apply(whitelister, params)

    assert updated_params == %{
      name: "John",
      email: "john@wayne.com"
    }
  end
end
