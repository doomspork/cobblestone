defmodule Cobblestone.Parser do
  @moduledoc """
  Parser module for processing path expressions in the Cobblestone library.

  This module provides parsing functionality to convert string-based path expressions
  into structured tokens that can be used for data traversal. It leverages generated
  lexer and parser modules to tokenize and parse path expressions.
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
    message
    |> Enum.map(&to_string/1)
    |> Enum.join("")
    |> String.replace("syntax error before: ", "Unexpected token: ")
  end

  defp format_parser_error(message), do: to_string(message)

  defp format_lexer_error(:illegal), do: "Illegal character in path expression"
  defp format_lexer_error(reason), do: "Lexer error: #{reason}"
end
