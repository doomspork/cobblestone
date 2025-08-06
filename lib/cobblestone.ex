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
  {:ok, ["ABC", "XYZ", "123"]}

  iex> source = %{"data" => [%{"sku" => "ABC"}, %{"sku" => "XYZ"}, %{"sku" => "123"}]}
  iex> Cobblestone.get_at_path(source, ".data[0].sku")
  {:ok, ["ABC"]}

  iex> source = %{"data" => [%{"sku" => "ABC"}, %{"sku" => "XYZ"}, %{"sku" => "123"}]}
  iex> Cobblestone.get_at_path(source, ".data[0,2].sku")
  {:ok, ["ABC", "123"]}

  iex> source = %{"data" => [%{"sku" => "ABC"}, %{"sku" => "XYZ"}, %{"sku" => "123"}]}
  iex> Cobblestone.get_at_path(source, ".data[:2].sku")
  {:ok, ["ABC", "XYZ"]}

  """
  def get_at_path(enumerable, path) do
    case Parser.parse(path) do
      {:ok, tokens} ->
        case Path.walk(enumerable, tokens) do
          nil -> {:error, %{type: :no_match, path: path, message: "Path not found in data structure"}}
          result -> {:ok, result}
        end
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Like get_at_path/2 but returns the result directly or raises on error.
  Useful for pipeline operations where you want to fail fast.
  """
  def get_at_path!(enumerable, path) do
    case get_at_path(enumerable, path) do
      {:ok, result} -> result
      {:error, %{message: message}} -> raise ArgumentError, message
    end
  end

  @doc """
  Pipeline-friendly version that takes path as first argument.
  Useful for creating reusable query functions.

  ## Examples

      iex> query = Cobblestone.at(".store.book[].title")
      iex> data = %{"store" => %{"book" => [%{"title" => "Test"}]}}
      iex> query.(data)
      {:ok, ["Test"]}

      iex> get_price = Cobblestone.at(".price")
      iex> %{"price" => 10} |> get_price.()
      {:ok, 10}
  """
  def at(path) do
    fn enumerable -> get_at_path(enumerable, path) end
  end

  @doc """
  Pipeline-friendly version that returns results directly.
  Raises on error.

  ## Examples

      iex> get_price = Cobblestone.at!(".price")
      iex> %{"price" => 10} |> get_price.()
      10
  """
  def at!(path) do
    fn enumerable -> get_at_path!(enumerable, path) end
  end

  @doc """
  Transform data using multiple path expressions.
  Returns a map with results from each path.

  ## Examples

      iex> data = %{"user" => %{"name" => "John", "age" => 30}}
      iex> Cobblestone.extract(data, %{name: ".user.name", age: ".user.age"})
      {:ok, %{name: "John", age: 30}}
  """
  def extract(enumerable, path_map) when is_map(path_map) do
    results =
      Enum.reduce_while(path_map, {:ok, %{}}, fn {key, path}, {:ok, acc} ->
        case get_at_path(enumerable, path) do
          {:ok, value} -> {:cont, {:ok, Map.put(acc, key, value)}}
          {:error, _} = error -> {:halt, error}
        end
      end)

    case results do
      {:ok, result_map} -> {:ok, result_map}
      error -> error
    end
  end

  @doc """
  Like extract/2 but raises on error and returns the result map directly.
  """
  def extract!(enumerable, path_map) do
    case extract(enumerable, path_map) do
      {:ok, result} -> result
      {:error, %{message: message}} -> raise ArgumentError, message
    end
  end
end
