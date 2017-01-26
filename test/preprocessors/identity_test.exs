defmodule Validation.Preprocessors.IdentityTest do
  use ExUnit.Case, async: true

  alias Validation.Preprocessor
  alias Validation.Preprocessors.Identity

  test "identity preprocessor" do
    identity = Identity.build
    params = %{name: "John"}

    assert Preprocessor.apply(identity, params) == params
  end
end
