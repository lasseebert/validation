defmodule Validation.Predicates.And do
  @moduledoc """
  Built-in predicate that combines two other predicates with `and`
  """

  alias Validation.Predicate

  @spec build(Predicate.t, Predicate.t) :: Predicate.t
  def build(left, right) do
    composer = fn [left, right] ->
      fn value ->
        with :ok <- left.val.(value) do
          right.val.(value)
        end
      end
    end

    Predicate.build_composed([left, right], composer, "and")
  end
end
