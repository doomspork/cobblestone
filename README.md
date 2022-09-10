# Cobblestone

> A better path to data

Experimental. Exploring leex, yecc, and data access.

Inspired by [jq](https://stedolan.github.io/jq/), [JSONPath](https://goessner.net/articles/JsonPath/), and XPath.

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

| XPath                | JSONPath                                | Cobblestone                           | Result                                                      |
| -------------------- | --------------------------------------- | ------------------------------------- | ----------------------------------------------------------- |
| /store/book/author   | $.store.book[*].author                  | .store.book[].author                  | the authors of all books in the store                       |
| //author             | $..author                               | Not Yet Supported                     | all authors                                                 |
| /store/\*            | $.store.\*                              | .store                                | all things in store, which are some books and a red bicycle |
| /store//price        | $.store..price                          | Not Yet Supported                     | the price of everything in the store.                       |
| //book[3]            | $..book[2]                              | .store.book[2]                        | the third book                                              |
| //book[last()]       | $..book[(@.length-1)]<br />$..book[-1:] | .store.book[-1]                       | the last book in order.                                     |
| //book[position()<3] | $..book[0,1]<br />$..book[:2]           | .store.book[0,1]<br />.store.book[:2] | the first two books                                         |
| //book[isbn]         | $..book[?(@.isbn)]                      | .store.book[isbn]                     | filter all books with isbn number                           |
| //book[price<10]     | $..book[?(@.price<10)]                  | .store.book[price<10]                 | filter all books cheapier than 10                           |
| //\*                 | $..\*                                   | .                                     | all Elements in structure.                                  |

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cobblestone` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cobblestone, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/cobblestone>.
