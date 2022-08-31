defmodule Cobblestone do
  @moduledoc """
  A better path to data.

  Experimental.
  """

  alias Cobblestone.{Parser, Path}

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
  iex> Cobblestone.get_at_path(source, ".data[:2].sku")
  ["ABC", "XYZ"]

  """
  def get_at_path(enumerable, path) do
    with {:ok, tokens} <- Parser.parse(path) do
      Path.walk(enumerable, tokens)
    end
  end
end
