defmodule Validation.Schema do
  @moduledoc """
  A schema is a collection of rules
  """

  alias Validation.Rule

  defstruct [
    rules: []
  ]

  @doc """
  Define a schema

  Usage:

    require Validation.Schema
    name_schema = Validation.Schema.define do
      optional(:first_name, filled and string)
      required(:last_name, filled and string)
    end
  """
  defmacro define(do: {:__block__, _, quoted_rules}) do
    define_quoted(quoted_rules)
  end
  defmacro define(do: rule) do
    define_quoted([rule])
  end

  defp define_quoted(quoted_rules) do
    rules =
      quoted_rules
      |> build_rules

    %Validation.Schema{rules: rules}
    |> Macro.escape
  end

  defp build_rules([]) do
    []
  end
  defp build_rules([quoted_rule | rest]) do
    rule = Rule.build_rule(quoted_rule)
    [rule | build_rules(rest)]
  end
end
