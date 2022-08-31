defmodule Cobblestone.Path do
  def walk(input, steps), do: walk_path(input, steps)

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

  defp walk_path(input, [step | steps]) when is_list(step) do
    indices = unfold_indices(input, step)

    {_, result} =
      Enum.reduce(input, {0, []}, fn curr, {index, acc} ->
        if index in indices do
          {index + 1, [curr | acc]}
        else
          {index + 1, acc}
        end
      end)

    result
    |> Enum.reverse()
    |> walk_path(steps)
  end

  defp unfold_indices(input, indices) do
    indices
    |> Enum.reduce([], &(&2 ++ unfold_indice(input, &1)))
    |> Enum.uniq()
  end

  defp unfold_indice(_input, {nil, stop}), do: Enum.to_list(0..(stop - 1))
  defp unfold_indice(input, {start, nil}), do: Enum.to_list(start..length(input))
  defp unfold_indice(_input, {start, stop}), do: Enum.to_list(start..(stop - 1))
  defp unfold_indice(input, index) when index < 0, do: [length(input) + index]
  defp unfold_indice(_input, index), do: [index]
end
