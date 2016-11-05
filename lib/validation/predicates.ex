defmodule Validation.Predicates do
  @moduledoc """
  Built-in predicates
  """

  def filled?(value) do
    !empty(value)
  end

  def empty(%{}), do: true
  def empty([]), do: true
  def empty(""), do: true
  def empty(nil), do: true
  def empty(_), do: false

  def type?(value, :string) when is_binary(value), do: true
  def type?(_value, :string), do: false

  def match?(value, pattern) when is_binary(value) do
    value |> String.match?(pattern)
  end
  def match?(_, _) do
    false
  end
end
