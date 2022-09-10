defmodule Cobblestone.Path do
  def walk(input, steps) do
    walk_path(input, steps)
  end

  defp walk_path(input, []) do
    input
  end

  defp walk_path(inputs, [{:local, step} | steps]) when is_list(inputs) do
    inputs
    |> Enum.map(&Map.get(&1, step))
    |> walk_path(steps)
  end

  defp walk_path(input, [{:local, step} | steps]) do
    input
    |> Map.get(step)
    |> walk_path(steps)
  end

  defp walk_path(input, [[] | steps]) do
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
