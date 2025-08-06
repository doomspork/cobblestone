defmodule Cobblestone do
  @moduledoc """
  A powerful data querying and transformation library for Elixir, inspired by jq, JSONPath, and XPath.

  Cobblestone provides a path-based query language for navigating and filtering nested maps and lists,
  with support for complex operations like filtering, transformation, and pipeline chaining.

  ## Features

  - **Path Navigation**: Direct access (`.store.book`) and recursive search (`..author`)
  - **Array Operations**: Indexing (`[0]`, `[-1]`), slicing (`[1:3]`), multiple indices (`[0,2,4]`)
  - **Filtering**: Existence filters (`[isbn]`) and comparison filters (`[price>20]`)
  - **Data Transformation**: `map()` for transforming arrays, `select()` for filtering
  - **Pipeline Operations**: Chain operations with the pipe operator (`|`)
  - **Elixir Integration**: Supports both atom and string keys, pipeline-friendly APIs
  - **Error Handling**: Structured error responses with helpful messages

  ## Quick Examples

      iex> data = %{"store" => %{"book" => [%{"title" => "Elixir Guide", "price" => 25}]}}
      iex> Cobblestone.get_at_path(data, ".store.book[].title")
      {:ok, ["Elixir Guide"]}

      iex> books = [%{title: "Book 1", active: true}, %{title: "Book 2", active: false}]
      iex> Cobblestone.get_at_path!(books, "[] | select(.active) | map(.title)")
      ["Book 1"]

  ## Path Syntax

  - `.key` - Access map key
  - `..key` - Recursive search for key
  - `[n]` - Array index (supports negative indices)
  - `[n:m]` - Array slice
  - `[n,m,o]` - Multiple array indices
  - `[]` - Array/object iterator
  - `[key]` - Filter by key existence
  - `[key>value]` - Filter by comparison
  - `expr | expr` - Pipeline operations
  - `select(condition)` - Filter elements
  - `map(expression)` - Transform arrays

  ## Error Handling

  Functions return `{:ok, result}` on success and `{:error, details}` on failure.
  Use the `!` variants (e.g., `get_at_path!/2`) for direct results that raise on error.
  """

  alias Cobblestone.{Parser, Path}

  @doc """
  Query data using path expressions, returning `{:ok, result}` or `{:error, details}`.

  ## Basic Path Navigation

      iex> data = %{"user" => %{"name" => "Alice", "age" => 30}}
      iex> Cobblestone.get_at_path(data, ".user.name")
      {:ok, "Alice"}

      iex> data = %{"users" => [%{"name" => "Alice"}, %{"name" => "Bob"}]}
      iex> Cobblestone.get_at_path(data, ".users[0].name")
      {:ok, ["Alice"]}

  ## Array Operations

      iex> data = %{"items" => ["a", "b", "c", "d"]}
      iex> Cobblestone.get_at_path(data, ".items[1:3]")
      {:ok, ["b", "c"]}

      iex> data = %{"items" => ["a", "b", "c", "d"]}
      iex> Cobblestone.get_at_path(data, ".items[-1]")
      {:ok, ["d"]}

      iex> data = %{"items" => ["a", "b", "c", "d"]}
      iex> Cobblestone.get_at_path(data, ".items[0,2]")
      {:ok, ["a", "c"]}

  ## Collection Processing

      iex> data = %{"products" => [%{"name" => "Phone", "price" => 500}, %{"name" => "Laptop", "price" => 1000}]}
      iex> Cobblestone.get_at_path(data, ".products[].name")
      {:ok, ["Phone", "Laptop"]}

      iex> data = %{"store" => %{"book" => %{"title" => "Guide"}, "music" => %{"album" => "Hits"}}}
      iex> Cobblestone.get_at_path(data, ".store[]")
      {:ok, [%{"title" => "Guide"}, %{"album" => "Hits"}]}

  ## Filtering

      iex> books = [%{"title" => "Book A", "price" => 20}, %{"title" => "Book B", "price" => 35, "isbn" => "123"}]
      iex> Cobblestone.get_at_path(books, ".[isbn]")
      {:ok, [%{"title" => "Book B", "price" => 35, "isbn" => "123"}]}

      iex> books = [%{"title" => "Book A", "price" => 20}, %{"title" => "Book B", "price" => 35}]
      iex> Cobblestone.get_at_path(books, ".[price>25]")
      {:ok, [%{"title" => "Book B", "price" => 35}]}

  ## Recursive Search

      iex> data = %{"store" => %{"inventory" => %{"books" => [%{"author" => "Smith"}]}, "catalog" => %{"author" => "Jones"}}}
      iex> Cobblestone.get_at_path(data, "..author")
      {:ok, ["Jones", "Smith"]}

  ## Pipeline Operations

      iex> books = [%{"title" => "A", "active" => false}, %{"title" => "B", "active" => true}, %{"title" => "C", "active" => true}]
      iex> Cobblestone.get_at_path(books, ".[] | select(.active) | map(.title)")
      {:ok, ["B", "C"]}

  ## Atom Key Support

      iex> data = %{users: [%{name: "Alice", active: true}, %{name: "Bob", active: false}]}
      iex> Cobblestone.get_at_path(data, ".users[].name")
      {:ok, ["Alice", "Bob"]}

  ## Error Handling

      iex> data = %{"user" => %{"name" => "Alice"}}
      iex> {:error, %{type: :no_match}} = Cobblestone.get_at_path(data, ".user.nonexistent")

      iex> data = %{"user" => %{"name" => "Alice"}}
      iex> {:error, %{type: :parse_error}} = Cobblestone.get_at_path(data, ".user[incomplete")

  """
  def get_at_path(enumerable, path) do
    case Parser.parse(path) do
      {:ok, tokens} ->
        case Path.walk(enumerable, tokens) do
          nil -> {:error, %{type: :no_match, path: path, message: "Path not found in data structure"}}
          result -> {:ok, result}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Like get_at_path/2 but returns the result directly or raises on error.

  Use this when you want fail-fast behavior or when you're confident the path exists.
  Perfect for pipeline operations where you want to raise on any error.

  ## Examples

      iex> data = %{"user" => %{"profile" => %{"email" => "user@example.com"}}}
      iex> Cobblestone.get_at_path!(data, ".user.profile.email")
      "user@example.com"

      iex> products = [%{"name" => "Laptop", "price" => 999}, %{"name" => "Phone", "price" => 599}]
      iex> Cobblestone.get_at_path!(products, ".[].name")
      ["Laptop", "Phone"]

      iex> inventory = %{items: [%{id: 1, active: true}, %{id: 2, active: false}, %{id: 3, active: true}]}
      iex> Cobblestone.get_at_path!(inventory, ".items[] | select(.active)")
      [%{id: 1, active: true}, %{id: 3, active: true}]

      iex> data = %{config: %{database: %{host: "localhost", port: 5432}}}
      iex> Cobblestone.get_at_path!(data, ".config.database")
      %{host: "localhost", port: 5432}

  ## Error Behavior

  Raises `ArgumentError` with a descriptive message on any error:

      iex> data = %{"user" => %{"name" => "Alice"}}
      iex> Cobblestone.get_at_path!(data, ".user.nonexistent")
      ** (ArgumentError) Path not found in data structure

      iex> Cobblestone.get_at_path!(%{}, ".invalid[incomplete")
      ** (ArgumentError) Unexpected token:

  """
  def get_at_path!(enumerable, path) do
    case get_at_path(enumerable, path) do
      {:ok, result} -> result
      {:error, %{message: message}} -> raise ArgumentError, message
    end
  end

  @doc """
  Creates a reusable query function for the given path expression.

  Returns a function that takes data and applies the path query, returning
  `{:ok, result}` or `{:error, details}`. Perfect for creating reusable
  data extraction functions.

  ## Examples

      iex> get_user_name = Cobblestone.at(".user.name")
      iex> data = %{"user" => %{"name" => "Alice", "age" => 30}}
      iex> get_user_name.(data)
      {:ok, "Alice"}

      iex> extract_prices = Cobblestone.at(".products[].price")
      iex> catalog = %{"products" => [%{"name" => "A", "price" => 10}, %{"name" => "B", "price" => 20}]}
      iex> extract_prices.(catalog)
      {:ok, [10, 20]}

  ## Pipeline Usage

      iex> get_active_users = Cobblestone.at(".users[] | select(.active)")
      iex> data = %{"users" => [%{"name" => "Alice", "active" => true}, %{"name" => "Bob", "active" => false}]}
      iex> data |> get_active_users.()
      {:ok, [%{"name" => "Alice", "active" => true}]}

  ## Function Composition

      iex> get_config = Cobblestone.at(".app.config")
      iex> get_titles = Cobblestone.at(".items[].title")
      iex>
      iex> # You can store and reuse these query functions
      iex> queries = %{config: get_config, titles: get_titles}
      iex> data = %{"app" => %{"config" => %{"debug" => true}}, "items" => [%{"title" => "Item 1"}]}
      iex> queries.config.(data)
      {:ok, %{"debug" => true}}

  """
  def at(path) do
    fn enumerable -> get_at_path(enumerable, path) end
  end

  @doc """
  Creates a reusable query function that returns results directly or raises on error.

  Like `at/1` but the returned function will raise `ArgumentError` on any error
  instead of returning error tuples. Perfect for fail-fast scenarios.

  ## Examples

      iex> get_email = Cobblestone.at!(".user.email")
      iex> user_data = %{"user" => %{"email" => "alice@example.com", "age" => 25}}
      iex> get_email.(user_data)
      "alice@example.com"

      iex> extract_names = Cobblestone.at!(".team[].name")
      iex> team_data = %{"team" => [%{"name" => "Alice"}, %{"name" => "Bob"}]}
      iex> extract_names.(team_data)
      ["Alice", "Bob"]

  ## Pipeline Chains

      iex> get_active_items = Cobblestone.at!(".inventory[] | select(.active)")
      iex> inventory = %{"inventory" => [%{"name" => "Laptop", "active" => true}, %{"name" => "Mouse", "active" => false}]}
      iex> get_active_items.(inventory)
      [%{"name" => "Laptop", "active" => true}]

  ## Error Handling

  Functions created by `at!/1` will raise on any error:

      iex> get_missing = Cobblestone.at!(".nonexistent.field")
      iex> get_missing.(%{"data" => "value"})
      ** (ArgumentError) Path not found in data structure

      iex> invalid_query = Cobblestone.at!(".invalid[incomplete")
      iex> invalid_query.(%{})
      ** (ArgumentError) Unexpected token:

  """
  def at!(path) do
    fn enumerable -> get_at_path!(enumerable, path) end
  end

  @doc """
  Extract multiple values from data using a map of path expressions.

  Takes a data structure and a map where keys are result names and values
  are path expressions. Returns `{:ok, result_map}` with extracted values,
  or `{:error, details}` if any path fails.

  ## Examples

      iex> user = %{"profile" => %{"name" => "Alice", "email" => "alice@example.com"}, "settings" => %{"theme" => "dark"}}
      iex> paths = %{name: ".profile.name", email: ".profile.email", theme: ".settings.theme"}
      iex> Cobblestone.extract(user, paths)
      {:ok, %{name: "Alice", email: "alice@example.com", theme: "dark"}}

      iex> data = %{"products" => [%{"name" => "A", "price" => 10}, %{"name" => "B", "price" => 20}]}
      iex> queries = %{names: ".products[].name", prices: ".products[].price", all_products: ".products"}
      iex> Cobblestone.extract(data, queries)
      {:ok, %{names: ["A", "B"], prices: [10, 20], all_products: [%{"name" => "A", "price" => 10}, %{"name" => "B", "price" => 20}]}}

  ## Complex Extractions

      iex> ecommerce = %{
      ...>   "store" => %{
      ...>     "products" => [%{"name" => "Laptop", "price" => 999, "category" => "tech"}],
      ...>     "orders" => [%{"id" => 1, "total" => 999}]
      ...>   },
      ...>   "users" => [%{"name" => "Alice", "active" => true}]
      ...> }
      iex> extractions = %{
      ...>   product_names: ".store.products[].name",
      ...>   order_totals: ".store.orders[].total",
      ...>   active_users: ".users[] | select(.active)"
      ...> }
      iex> Cobblestone.extract(ecommerce, extractions)
      {:ok, %{product_names: ["Laptop"], order_totals: [999], active_users: [%{"name" => "Alice", "active" => true}]}}

  ## Atom Keys

      iex> config = %{database: %{host: "localhost", port: 5432}, cache: %{ttl: 3600}}
      iex> settings = %{db_host: ".database.host", db_port: ".database.port", cache_ttl: ".cache.ttl"}
      iex> Cobblestone.extract(config, settings)
      {:ok, %{db_host: "localhost", db_port: 5432, cache_ttl: 3600}}

  ## Error Handling

      iex> data = %{"user" => %{"name" => "Alice"}}
      iex> paths = %{name: ".user.name", age: ".user.age", invalid: ".user.missing"}
      iex> {:error, %{type: :no_match}} = Cobblestone.extract(data, paths)

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
  Like extract/2 but returns the result map directly or raises on error.

  Perfect for cases where you expect all paths to succeed and want
  fail-fast behavior.

  ## Examples

      iex> api_response = %{"data" => %{"user" => %{"id" => 123, "name" => "Alice"}}, "meta" => %{"version" => "1.0"}}
      iex> fields = %{user_id: ".data.user.id", user_name: ".data.user.name", api_version: ".meta.version"}
      iex> Cobblestone.extract!(api_response, fields)
      %{user_id: 123, user_name: "Alice", api_version: "1.0"}

      iex> metrics = %{stats: [%{name: "cpu", value: 85}, %{name: "memory", value: 70}]}
      iex> reports = %{metric_names: ".stats[].name", metric_values: ".stats[].value"}
      iex> Cobblestone.extract!(metrics, reports)
      %{metric_names: ["cpu", "memory"], metric_values: [85, 70]}

  ## Error Behavior

      iex> data = %{"user" => %{"name" => "Alice"}}
      iex> paths = %{name: ".user.name", missing: ".user.nonexistent"}
      iex> Cobblestone.extract!(data, paths)
      ** (ArgumentError) Path not found in data structure

  """
  def extract!(enumerable, path_map) do
    case extract(enumerable, path_map) do
      {:ok, result} -> result
      {:error, %{message: message}} -> raise ArgumentError, message
    end
  end
end
