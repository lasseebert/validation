defmodule Validation.ResultTest do
  use ExUnit.Case, async: true

  alias Validation.Result

  describe "merge_errors/2" do
    test "merging no errors" do
      result =
        %Result{errors: %{name: ["is missing"]}}
        |> Result.merge_errors(%{})

      assert result.errors == %{name: ["is missing"]}
    end

    test "merging into empty errors" do
      result =
        %Result{}
        |> Result.merge_errors(%{name: ["is missing"]})

      assert result.errors == %{name: ["is missing"]}
    end

    test "merging errors with same key" do
      result =
        %Result{errors: %{name: ["is invalid"]}}
        |> Result.merge_errors(%{name: ["is missing"]})

      assert result.errors == %{name: ["is invalid", "is missing"]}
    end

    test "merging errors with same key and message" do
      result =
        %Result{errors: %{name: ["is missing"]}}
        |> Result.merge_errors(%{name: ["is missing"]})

      assert result.errors == %{name: ["is missing"]}
    end
  end
end
