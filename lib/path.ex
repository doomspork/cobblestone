defmodule Cobblestone.Path do
  @moduledoc """
  Provides functionality for walking and navigating through nested data structures
  using parsed path expressions.

  This module implements the core data traversal engine for Cobblestone. It takes
  parsed AST tokens from the parser and executes them against data structures,
  supporting complex operations like filtering, transformation, and pipeline chaining.

  ## Supported Operations

  - **Local Navigation**: `.key` - Access map keys directly
  - **Global Search**: `..key` - Recursively find all instances of a key
  - **Array Operations**: `[n]`, `[n:m]`, `[n,m,o]` - Index, slice, multi-select
  - **Collection Iteration**: `[]` - Iterate over arrays or map values
  - **Filtering**: `[key]`, `[key>value]` - Filter by existence or comparison
  - **Functions**: `select(condition)`, `map(expression)` - Advanced data processing
  - **Pipeline Chaining**: `expr | expr` - Chain operations together

  ## Key Features

  - **Mixed Key Support**: Works with both string and atom keys
  - **Type Safety**: Graceful handling of type mismatches
  - **Error Resilience**: Returns `nil` for missing paths rather than crashing
  - **Performance**: Efficient traversal with minimal memory allocation

  ## Examples

      iex> data = %{"users" => [%{"name" => "Alice", "active" => true}]}
      iex> steps = [{:local, "users"}, {:iterator}, {:local, "name"}]
      iex> Cobblestone.Path.walk(data, steps)
      ["Alice"]

      iex> data = [%{id: 1, active: true}, %{id: 2, active: false}]
      iex> steps = [{:iterator}, {:function, "select", [[{:local, "active"}]]}]
      iex> Cobblestone.Path.walk(data, steps)
      [%{id: 1, active: true}]

  The module is typically not used directly - instead use the high-level
  `Cobblestone.get_at_path/2` functions which handle parsing and error management.
  """

  def walk(input, steps) do
    walk_path(input, steps)
  end

  # All all_matches/3 clauses grouped together
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
        keys_match?(key, search) and is_list(value) -> value
        keys_match?(key, search) -> [value]
        true -> []
      end

    all_matches(value, search, sub_acc) ++ all_matches(tail, search, acc)
  end

  defp all_matches(_tail, _search, acc) do
    acc
  end

  # All walk_path/2 clauses grouped together
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
    |> Enum.map(&get_key(&1, key))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:local, key} | steps]) do
    input
    |> get_key(key)
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

  defp walk_path(input, [{:function, "select", [condition]} | steps]) when is_list(input) do
    # Apply select to each element in a list
    input
    |> Enum.filter(fn item ->
      case walk_path(item, condition) do
        true -> true
        false -> false
        nil -> false
        [] -> false
        _ -> true
      end
    end)
    |> walk_path(steps)
  end

  defp walk_path(input, [{:function, "select", [condition]} | steps]) do
    # Apply select to a single item
    case walk_path(input, condition) do
      true -> walk_path(input, steps)
      false -> nil
      nil -> nil
      [] -> nil
      _ -> walk_path(input, steps)
    end
  end

  defp walk_path(input, [{:function, "map", [expr]} | steps]) when is_list(input) do
    # Apply map to transform each element
    input
    |> Enum.map(fn item -> walk_path(item, expr) end)
    |> walk_path(steps)
  end

  defp walk_path(input, [{:object, fields} | steps]) do
    # Build object from field specifications
    result =
      Enum.reduce(fields, %{}, fn {key, value_path}, acc ->
        value = walk_path(input, value_path)
        Map.put(acc, key, value)
      end)

    walk_path(result, steps)
  end

  defp walk_path(input, [{:array, elements} | steps]) do
    # Build array from element specifications
    result =
      Enum.map(elements, fn element_path ->
        walk_path(input, element_path)
      end)

    walk_path(result, steps)
  end

  defp walk_path(input, [{:function, _name, _args} | steps]) do
    # Unknown function, pass through for now
    walk_path(input, steps)
  end

  defp walk_path(input, [{:filter, {key, op, val}} | steps]) do
    input
    |> Enum.filter(&compare(&1, key, op, val))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:filter, step} | steps]) do
    input
    |> Enum.filter(&has_key?(&1, step))
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

  # Helper functions
  defp keys_match?(key, search) when is_binary(search) do
    key == search or (is_atom(key) and Atom.to_string(key) == search)
  end

  defp keys_match?(key, search), do: key == search

  # Helper function to get key from map, trying both string and atom versions
  defp get_key(map, key) when is_map(map) and is_binary(key) do
    Map.get(map, key) || Map.get(map, String.to_existing_atom(key))
  rescue
    ArgumentError -> Map.get(map, key)
  end

  defp get_key(map, key) when is_map(map), do: Map.get(map, key)
  defp get_key(_, _), do: nil

  # Helper to check if map has key, supporting both string and atom keys
  defp has_key?(map, key) when is_map(map) and is_binary(key) do
    Map.has_key?(map, key) or Map.has_key?(map, String.to_existing_atom(key))
  rescue
    ArgumentError -> Map.has_key?(map, key)
  end

  defp has_key?(map, key) when is_map(map), do: Map.has_key?(map, key)
  defp has_key?(_, _), do: false

  defp compare(input, key, op, right) do
    left = get_key(input, key)
    apply(Kernel, String.to_existing_atom(op), [left, right])
  end
end
