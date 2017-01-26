defmodule Validation.Preprocessors.Identity do
  @moduledoc """
  The preprocessor that returns the input params untouched.
  This can be used as a default preprocessor.
  """

  alias Validation.Preprocessor

  @spec build() :: Preprocessor.t
  def build do
    Preprocessor.build(&(&1), type: "identity")
  end
end
