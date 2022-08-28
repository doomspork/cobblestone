defmodule Cobblestone do
  @moduledoc """
  A better path to data.

  Experimental.
  """

  @doc """
  Example

  iex> source = %{"data" => [%{"sku" => "ABC"}, %{"sku" => "XYZ"}, %{"sku" => "123"}]}
  iex> Cobblestone.get_at_path(source, ".data[].sku")
  ["ABC", "XYZ", "123"]

  iex> source = %{"data" => [%{"sku" => "ABC"}, %{"sku" => "XYZ"}, %{"sku" => "123"}]}
  iex> Cobblestone.get_at_path(source, ".data[0].sku")
  ["ABC"]

  iex> source = %{"data" => [%{"sku" => "ABC"}, %{"sku" => "XYZ"}, %{"sku" => "123"}]}
  iex> Cobblestone.get_at_path(source, ".data[0,2].sku")
  ["ABC", "123"]

  iex> source = %{"data" => [%{"sku" => "ABC"}, %{"sku" => "XYZ"}, %{"sku" => "123"}]}
  iex> Cobblestone.get_at_path(source, ".data[1:2].sku")
  ["XYZ", "123"]
  """
  def get_at_path(enumerable, path) do
    with {:ok, tokens} <- parse(path) do
      walk_path(enumerable, tokens)
    end
  end

  defp walk_path(input, []) do
    input
  end

  defp walk_path(inputs, [step | steps]) when is_binary(step) and is_list(inputs) do
    inputs
    |> Enum.map(&Map.get(&1, step))
    |> walk_path(steps)
  end

  defp walk_path(input, [step | steps]) when is_binary(step) do
    input
    |> Map.get(step)
    |> walk_path(steps)
  end

  defp walk_path(inputs, [[] | steps]) do
    walk_path(inputs, steps)
  end

  defp walk_path(inputs, [step | steps]) when is_list(step) do
    {_, result} =
      Enum.reduce(inputs, {0, []}, fn input, {index, acc} ->
        if index in step do
          {index + 1, [input | acc]}
        else
          {index + 1, acc}
        end
      end)

    result
    |> Enum.reverse()
    |> walk_path(steps)
  end

  defp parse(path) do
    input = to_charlist(path)

    with {:ok, tokens, _} <- :cs_lexer.string(input) do
      :cs_parser.parse(tokens)
    end
  end
end
