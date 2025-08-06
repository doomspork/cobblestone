defmodule Cobblestone.Path do
  @moduledoc """
  Provides functionality for walking and navigating through nested data structures
  using path expressions similar to JSONPath.

  The main entry point is `walk/2` which takes input data and a list of path steps
  to traverse the data structure. Supports various operations including:
  - Local and global key access
  - Array filtering and indexing
  - Recursive searches through nested structures
  """

  def walk(input, steps) do
    walk_path(input, steps)
  end

  defp all_matches(value, search, acc) when is_map(value) do
    value
    |> Map.to_list()
    |> all_matches(search, acc)
  end

  defp all_matches([value | tail], search, acc) when is_map(value) do
    all_matches(Map.to_list(value) ++ tail, search, acc)
  end

  defp all_matches([{key, value} | tail], search, acc) when is_map(value) do
    all_matches([{key, Map.to_list(value)} | tail], search, acc)
  end

  defp all_matches([{key, value} | tail], search, acc) do
    sub_acc =
      cond do
        key == search and is_list(value) -> value
        key == search -> [value]
        true -> []
      end

    all_matches(value, search, sub_acc) ++ all_matches(tail, search, acc)
  end

  defp all_matches(_tail, _search, acc) do
    acc
  end

  defp walk_path(input, []) do
    input
  end

  defp walk_path(input, [{:identity} | steps]) do
    walk_path(input, steps)
  end

  defp walk_path(input, [{:pipe, left_steps, right_steps}]) do
    input
    |> walk_path(left_steps)
    |> walk_path(right_steps)
  end

  defp walk_path(input, [{:global, key} | steps]) do
    input
    |> all_matches(key, [])
    |> walk_path(steps)
  end

  defp walk_path(inputs, [{:local, key} | steps]) when is_list(inputs) do
    inputs
    |> Enum.map(&Map.get(&1, key))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:local, key} | steps]) do
    input
    |> Map.get(key)
    |> walk_path(steps)
  end

  defp walk_path(input, [{:iterator} | steps]) when is_list(input) do
    # For arrays, [] iterates over each element
    input
    |> Enum.flat_map(fn item ->
      result = walk_path(item, steps)
      if is_list(result), do: result, else: [result]
    end)
  end

  defp walk_path(input, [{:iterator} | steps]) when is_map(input) do
    # For objects, [] returns all values (not key-value pairs)
    input
    |> Map.values()
    |> walk_path(steps)
  end

  defp walk_path(input, [{:iterator} | steps]) do
    # For other types, just pass through
    walk_path(input, steps)
  end

  defp walk_path(input, [{:filter, {key, op, val}} | steps]) do
    input
    |> Enum.filter(&compare(&1, key, op, val))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:filter, step} | steps]) do
    input
    |> Enum.filter(&Map.has_key?(&1, step))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:indices, {first, nil}} | steps]) do
    input
    |> Enum.slice(first..length(input))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:indices, {nil, last}} | steps]) do
    input
    |> Enum.slice(0..(last - 1))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:indices, {first, last}} | steps]) do
    input
    |> Enum.slice(first..(last - 1))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:indices, indices} | steps]) do
    indices
    |> Enum.map(&Enum.at(input, &1))
    |> walk_path(steps)
  end

  defp compare(input, key, op, right) do
    left = Map.get(input, key)
    apply(Kernel, String.to_existing_atom(op), [left, right])
  end
end
