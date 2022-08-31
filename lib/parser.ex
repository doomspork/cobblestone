defmodule Cobblestone.Parser do
  def parse(path) do
    input = to_charlist(path)
    with {:ok, tokens, _} <- :cs_lexer.string(input) do
      :cs_parser.parse(tokens)
    end
  end
end
