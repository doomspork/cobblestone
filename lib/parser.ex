defmodule Cobblestone.Parser do
  @moduledoc """
  Parser module for processing path expressions in the Cobblestone library.

  This module provides parsing functionality to convert string-based path expressions
  into structured tokens that can be used for data traversal. It leverages generated
  lexer and parser modules to tokenize and parse path expressions.
  """

  def parse(path) do
    input = to_charlist(path)

    with {:ok, tokens, _} <- :cs_lexer.string(input) do
      :cs_parser.parse(tokens)
    end
  end
end
