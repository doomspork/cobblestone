defmodule Cobblestone.Parser do
  @moduledoc """
  Parser module for processing path expressions in the Cobblestone library.

  This module provides parsing functionality to convert string-based path expressions
  into structured tokens that can be used for data traversal. It leverages generated
  lexer and parser modules built with Erlang's :leex and :yecc tools.

  ## Error Handling

  The parser provides structured error responses with helpful context when
  parsing fails, rather than crashing or returning cryptic error tuples.

  ## Examples

      iex> Cobblestone.Parser.parse(".user.name")
      {:ok, [{:local, "user"}, {:local, "name"}]}

      iex> Cobblestone.Parser.parse(".items[0]")
      {:ok, [{:local, "items"}, {:indices, [0]}]}

      iex> Cobblestone.Parser.parse(".books[] | select(.price > 20)")
      {:ok, [{:pipe, [{:local, "books"}, {:iterator}], [{:function, "select", [[{:local, "price"}, {:cmp, ">", 20}]]}]}]}

      iex> {:error, %{type: :parse_error, message: message}} = Cobblestone.Parser.parse(".invalid[")
      iex> String.contains?(message, "Unexpected token")
      true

      iex> {:error, %{type: :lexer_error}} = Cobblestone.Parser.parse(".field@invalid")

  """

  def parse(path) do
    input = to_charlist(path)

    case :cs_lexer.string(input) do
      {:ok, tokens, _} ->
        case :cs_parser.parse(tokens) do
          {:ok, ast} -> {:ok, ast}
          {:error, {line, :cs_parser, message}} ->
            {:error, %{
              type: :parse_error,
              line: line,
              path: path,
              message: format_parser_error(message),
              raw_error: message
            }}
        end

      {:error, {line, :cs_lexer, {reason, _}}, _} ->
        {:error, %{
          type: :lexer_error,
          line: line,
          path: path,
          message: format_lexer_error(reason),
          raw_error: reason
        }}
    end
  end

  defp format_parser_error(message) when is_list(message) do
    Enum.map_join(message, "", &to_string/1)
    |> String.replace("syntax error before: ", "Unexpected token:")
  end

  defp format_parser_error(message), do: to_string(message)

  defp format_lexer_error(:illegal), do: "Illegal character in path expression"
  defp format_lexer_error(reason), do: "Lexer error: #{reason}"
end
