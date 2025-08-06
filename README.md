# Cobblestone

> A better path to data. Powerful data querying and transformation library for Elixir

[![Continuous Integration](https://github.com/doomspork/cobblestone/actions/workflows/ci.yaml/badge.svg)](https://github.com/doomspork/cobblestone/actions/workflows/ci.yaml)
[![Module Version](https://img.shields.io/hexpm/v/cobblestone.svg)](https://hex.pm/packages/cobblestone)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/cobblestone/)
[![Total Download](https://img.shields.io/hexpm/dt/cobblestone.svg)](https://hex.pm/packages/cobblestone)
[![License](https://img.shields.io/hexpm/l/cobblestone.svg)](https://github.com/doomspork/cobblestone/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/doomspork/cobblestone.svg)](https://github.com/doomspork/cobblestone/commits/main)

Cobblestone provides a path-based query language for navigating and filtering nested maps and lists in Elixir, inspired by jq, JSONPath, and XPath. It offers a simple yet powerful syntax for extracting, transforming, and manipulating data structures.

## Features

- **Path Navigation**: Direct access (`.store.book`) and recursive search (`..author`)
- **Array Operations**: Indexing (`[0]`, `[-1]`), slicing (`[1:3]`), multiple indices (`[0,2,4]`)
- **Filtering**: Existence filters (`[isbn]`) and comparison filters (`[price>20]`)
- **Data Transformation**: `map()` for transforming arrays, `select()` for filtering
- **Pipeline Operations**: Chain operations with the pipe operator (`|`)
- **Object/Array Construction**: Build new structures with `{key: .path}` and `[.path1, .path2]`
- **Elixir Integration**: Supports both atom and string keys, pipeline-friendly APIs
- **Error Handling**: Structured error responses with helpful messages

## Installation

Add `cobblestone` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cobblestone, "~> 0.1.0"}
  ]
end
```

## Quick Start

```elixir
# Basic path navigation
data = %{"user" => %{"name" => "Alice", "age" => 30}}
Cobblestone.get_at_path!(data, ".user.name")
# => "Alice"

# Array operations
books = %{"items" => [%{"title" => "Elixir in Action", "price" => 35}]}
Cobblestone.get_at_path!(books, ".items[0].title")
# => ["Elixir in Action"]

# Pipeline operations
users = [
  %{"name" => "Alice", "active" => true, "age" => 30},
  %{"name" => "Bob", "active" => false, "age" => 25}
]
Cobblestone.get_at_path!(users, ".[] | select(.active) | map(.name)")
# => ["Alice"]

# Object construction
user = %{"first" => "Alice", "last" => "Smith", "role" => "admin"}
Cobblestone.get_at_path!(user, "{name: .first, position: .role}")
# => %{"name" => "Alice", "position" => "admin"}
```

## Path Syntax Guide

### Basic Navigation

| Syntax | Description | Example |
|--------|-------------|---------|
| `.` | Identity (returns input) | `.` => entire structure |
| `.key` | Access map key | `.user.name` |
| `..key` | Recursive search | `..author` finds all authors |
| `.key1.key2` | Nested access | `.store.book` |

### Array Operations

| Syntax | Description | Example |
|--------|-------------|---------|
| `[n]` | Index access | `[0]` first, `[-1]` last |
| `[n:m]` | Slice range | `[1:3]` elements 1-2 |
| `[:m]` | Slice from start | `[:3]` first 3 elements |
| `[n:]` | Slice to end | `[2:]` from index 2 onward |
| `[n,m,o]` | Multiple indices | `[0,2,4]` specific elements |
| `[]` | Array/object iterator | `.items[]` all array elements |

### Filtering

| Syntax | Description | Example |
|--------|-------------|---------|
| `[key]` | Has key | `[isbn]` items with isbn field |
| `[key>value]` | Greater than | `[price>20]` |
| `[key<value]` | Less than | `[price<10]` |
| `[key>=value]` | Greater or equal | `[age>=18]` |
| `[key<=value]` | Less or equal | `[stock<=5]` |
| `[key==value]` | Equals | `[status=="active"]` |

### Functions

| Function | Description | Example |
|----------|-------------|---------|
| `select(expr)` | Filter elements | `select(.active)` |
| `map(expr)` | Transform elements | `map(.title)` |

### Construction

| Syntax | Description | Example |
|--------|-------------|---------|
| `{key: expr}` | Object construction | `{name: .first, age: .age}` |
| `[expr, expr]` | Array construction | `[.name, .email, .phone]` |

### Pipeline

| Syntax | Description | Example |
|--------|-------------|---------|
| `expr \| expr` | Chain operations | `.users \| select(.active) \| map(.name)` |

## API Reference

### Core Functions

#### `get_at_path(data, path)`

Query data using path expressions, returning `{:ok, result}` or `{:error, details}`.

```elixir
data = %{"users" => [%{"name" => "Alice"}, %{"name" => "Bob"}]}
{:ok, names} = Cobblestone.get_at_path(data, ".users[].name")
# => {:ok, ["Alice", "Bob"]}
```

#### `get_at_path!(data, path)`

Like `get_at_path/2` but returns the result directly or raises on error.

```elixir
Cobblestone.get_at_path!(data, ".users[].name")
# => ["Alice", "Bob"]
```

### Functional API

#### `at(path)`

Creates a reusable query function for the given path expression.

```elixir
get_names = Cobblestone.at(".users[].name")
{:ok, names} = get_names.(data)
```

#### `at!(path)`

Creates a reusable query function that raises on error.

```elixir
get_names = Cobblestone.at!(".users[].name")
names = get_names.(data)  # Raises on error
```

### Extraction Functions

#### `extract(data, path_map)`

Extract multiple values from data using a map of path expressions.

```elixir
paths = %{
  user_name: ".user.name",
  user_age: ".user.age",
  settings: ".user.settings"
}
{:ok, extracted} = Cobblestone.extract(data, paths)
```

#### `extract!(data, path_map)`

Like `extract/2` but raises on error.

```elixir
extracted = Cobblestone.extract!(data, paths)
```

## Advanced Examples

### Complex Data Extraction

```elixir
api_response = %{
  "data" => %{
    "users" => [
      %{"id" => 1, "name" => "Alice", "posts" => [%{"title" => "Hello"}]},
      %{"id" => 2, "name" => "Bob", "posts" => [%{"title" => "World"}]}
    ]
  },
  "meta" => %{"total" => 2}
}

# Extract multiple fields
Cobblestone.extract!(api_response, %{
  names: ".data.users[].name",
  total: ".meta.total",
  all_posts: ".data.users[].posts[].title"
})
# => %{names: ["Alice", "Bob"], total: 2, all_posts: ["Hello", "World"]}
```

### Data Transformation Pipeline

```elixir
products = [
  %{"name" => "Laptop", "price" => 999, "stock" => 5, "active" => true},
  %{"name" => "Mouse", "price" => 25, "stock" => 0, "active" => true},
  %{"name" => "Keyboard", "price" => 75, "stock" => 10, "active" => false}
]

# Complex pipeline: active products in stock, sorted by price
products
|> Cobblestone.get_at_path!(".[] | select(.active)")
|> Cobblestone.get_at_path!(".[stock>0]")
|> Cobblestone.get_at_path!("{name: .name, price: .price}")
# => %{"name" => "Laptop", "price" => 999}
```

### Working with Atom Keys

```elixir
# Cobblestone seamlessly handles atom keys
config = %{
  database: %{
    host: "localhost",
    port: 5432,
    credentials: %{
      username: "admin",
      password: "secret"
    }
  }
}

Cobblestone.get_at_path!(config, ".database.credentials.username")
# => "admin"
```

## Comparison with Similar Tools

Sample data structure used for comparison:

```elixir
%{
  "store" => %{
    "book" => [
      %{
        "category" => "reference",
        "author" => "Nigel Rees",
        "title" => "Sayings of the Century",
        "price" => 8.95
      },
      %{
        "category" => "fiction",
        "author" => "Evelyn Waugh",
        "title" => "Sword of Honour",
        "price" => 12.99
      },
      %{
        "category" => "fiction",
        "author" => "Herman Melville",
        "title" => "Moby Dick",
        "isbn" => "0-553-21311-3",
        "price" => 8.99
      },
      %{
        "category" => "fiction",
        "author" => "J. R. R. Tolkien",
        "title" => "The Lord of the Rings",
        "isbn" => "0-395-19395-8",
        "price" => 22.99
      }
    ],
    "bicycle" => %{
      "color" => "red",
      "price" => 19.95
    }
  }
}
```

### Query Syntax Comparison

| Use Case | XPath | JSONPath | jq | Cobblestone |
|----------|-------|----------|----|---------| 
| All book authors | `/store/book/author` | `$.store.book[*].author` | `.store.book[].author` | `.store.book[].author` |
| All authors (recursive) | `//author` | `$..author` | `.. \| .author? // empty` | `..author` |
| All store items | `/store/*` | `$.store.*` | `.store[]` | `.store[]` |
| All prices in store | `/store//price` | `$.store..price` | `.store \| .. \| .price? // empty` | `.store..price` |
| Third book | `//book[3]` | `$..book[2]` | `.store.book[2]` | `..book[2]` |
| Last book | `//book[last()]` | `$..book[-1:]` | `.store.book[-1]` | `..book[-1]` |
| First two books | `//book[position()<3]` | `$..book[:2]` | `.store.book[:2]` | `..book[:2]` |
| Books with ISBN | `//book[isbn]` | `$..book[?(@.isbn)]` | `.store.book[] \| select(.isbn)` | `..book[isbn]` |
| Books under $10 | `//book[price<10]` | `$..book[?(@.price<10)]` | `.store.book[] \| select(.price < 10)` | `..book[price<10]` |
| Books over $20 | `//book[price>20]` | `$..book[?(@.price>20)]` | `.store.book[] \| select(.price > 20)` | `..book[price>20]` |
| All elements | `//*` | `$..*` | `..` | `.` |
| Chain filters | N/A | `$.store.book[?(@.isbn)][?(@.price<10)]` | `.store.book[] \| select(.isbn) \| select(.price < 10)` | `.store.book \| [isbn] \| [price<10]` |
| Extract titles | N/A | `$.store.book[*].title` | `.store.book[].title` | `.store.book \| map(.title)` |
| Filter by field | N/A | `$.store.book[?(@.isbn)]` | `.store.book[] \| select(.isbn)` | `.store.book[] \| select(.isbn)` |
| Transform to object | N/A | N/A | `{title: .title, cost: .price}` | `{title: .title, cost: .price}` |
| Array construction | N/A | N/A | `[.name, .age, .email]` | `[.name, .age, .email]` |

### Key Differences

**Cobblestone vs JSONPath:**
- Cleaner, more intuitive syntax
- Native Elixir integration with atoms and strings
- Built-in pipeline operations
- Object/array construction support

**Cobblestone vs XPath:**
- JSON/Map-oriented rather than XML-focused
- Simpler array operations
- Modern functional operations (map, select)

**Cobblestone vs jq:**
- Native Elixir library (no external dependencies)
- Seamless integration with Elixir pipelines
- Simplified syntax for common operations
- Type-safe with Elixir's pattern matching

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

## Acknowledgments

- Inspired by [jq](https://stedolan.github.io/jq/), [JSONPath](https://goessner.net/articles/JsonPath/), and XPath
- Built with Erlang's leex and yecc parser generators
- Designed for the Elixir community