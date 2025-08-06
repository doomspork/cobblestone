defmodule CobblestoneTest do
  use ExUnit.Case
  doctest Cobblestone

  @sample %{
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

  describe "get_at_path/2" do
    test "supports `.key` paths" do
      assert %{
               "color" => "red",
               "price" => 19.95
             } == Cobblestone.get_at_path!(@sample, ".store.bicycle")

      assert "red" == Cobblestone.get_at_path!(@sample, ".store.bicycle.color")
    end

    test "supports `..key` paths" do
      assert ["red"] == Cobblestone.get_at_path!(@sample, "..color")
    end

    test "supports `.key..key` paths" do
      assert [19.95, 8.95, 12.99, 8.99, 22.99] == Cobblestone.get_at_path!(@sample, ".store..price")
    end

    test "supports [index]" do
      assert [
               %{
                 "category" => "reference",
                 "author" => "Nigel Rees",
                 "title" => "Sayings of the Century",
                 "price" => 8.95
               }
             ] == Cobblestone.get_at_path!(@sample, "..book[0]")
    end

    test "supports [index, index, index]" do
      assert [
               %{
                 "category" => "reference",
                 "author" => "Nigel Rees",
                 "title" => "Sayings of the Century",
                 "price" => 8.95
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
             ] == Cobblestone.get_at_path!(@sample, "..book[0,2,3]")
    end

    test "supports [index:index]" do
      assert [
               %{
                 "category" => "fiction",
                 "author" => "Evelyn Waugh",
                 "title" => "Sword of Honour",
                 "price" => 12.99
               }
             ] == Cobblestone.get_at_path!(@sample, "..book[1:2]")
    end

    test "supports [:index]" do
      assert [
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
               }
             ] == Cobblestone.get_at_path!(@sample, "..book[:2]")
    end

    test "supports [index:]" do
      assert [
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
             ] == Cobblestone.get_at_path!(@sample, "..book[2:]")
    end

    test "supports [-index]" do
      assert [
               %{
                 "category" => "fiction",
                 "author" => "J. R. R. Tolkien",
                 "title" => "The Lord of the Rings",
                 "isbn" => "0-395-19395-8",
                 "price" => 22.99
               }
             ] == Cobblestone.get_at_path!(@sample, "..book[-1]")

      assert [
               %{
                 "category" => "fiction",
                 "author" => "Herman Melville",
                 "title" => "Moby Dick",
                 "isbn" => "0-553-21311-3",
                 "price" => 8.99
               }
             ] == Cobblestone.get_at_path!(@sample, "..book[-2]")
    end

    test "supports [key]" do
      assert [
               %{
                 "author" => "Herman Melville",
                 "category" => "fiction",
                 "isbn" => "0-553-21311-3",
                 "price" => 8.99,
                 "title" => "Moby Dick"
               },
               %{
                 "author" => "J. R. R. Tolkien",
                 "category" => "fiction",
                 "isbn" => "0-395-19395-8",
                 "price" => 22.99,
                 "title" => "The Lord of the Rings"
               }
             ] == Cobblestone.get_at_path!(@sample, "..book[isbn]")
    end

    test "supports [key<val]" do
      assert [
               %{
                 "author" => "J. R. R. Tolkien",
                 "category" => "fiction",
                 "isbn" => "0-395-19395-8",
                 "price" => 22.99,
                 "title" => "The Lord of the Rings"
               }
             ] == Cobblestone.get_at_path!(@sample, "..book[price>20]")
    end

    test "supports pipe operator |" do
      # Get all books then filter by price
      assert [
               %{
                 "author" => "J. R. R. Tolkien",
                 "category" => "fiction",
                 "isbn" => "0-395-19395-8",
                 "price" => 22.99,
                 "title" => "The Lord of the Rings"
               }
             ] == Cobblestone.get_at_path!(@sample, ".store.book | [price>20]")

      # Chain multiple operations
      assert [
               %{
                 "author" => "Herman Melville",
                 "category" => "fiction",
                 "isbn" => "0-553-21311-3",
                 "price" => 8.99,
                 "title" => "Moby Dick"
               }
             ] == Cobblestone.get_at_path!(@sample, ".store.book | [isbn] | [price<10]")
    end

    test "supports identity filter ." do
      # Identity filter returns entire structure
      assert @sample == Cobblestone.get_at_path!(@sample, ".")

      # Identity filter with pipe
      assert %{
               "color" => "red",
               "price" => 19.95
             } == Cobblestone.get_at_path!(@sample, ".store.bicycle | .")
    end

    test "supports array/object iterator []" do
      # Iterate over array elements
      assert ["Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"] ==
               Cobblestone.get_at_path!(@sample, ".store.book[].author")

      # Get all prices from books
      assert [8.95, 12.99, 8.99, 22.99] ==
               Cobblestone.get_at_path!(@sample, ".store.book[].price")

      # Iterate over object values - should return values only
      result = Cobblestone.get_at_path!(@sample, ".store[]")
      # The result is a list containing the book array and bicycle map
      assert length(result) == 2
      assert @sample["store"]["bicycle"] in result
      assert @sample["store"]["book"] in result
    end

    test "supports select() function" do
      # Select books with isbn field (existence check)
      assert [
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
             ] == Cobblestone.get_at_path!(@sample, ".store.book[] | select(.isbn)")
    end

    test "supports map() function" do
      # Map to extract just titles
      assert ["Sayings of the Century", "Sword of Honour", "Moby Dick", "The Lord of the Rings"] ==
               Cobblestone.get_at_path!(@sample, ".store.book | map(.title)")

      # Map to extract authors
      assert ["Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"] ==
               Cobblestone.get_at_path!(@sample, ".store.book | map(.author)")
    end

    test "returns structured errors for invalid syntax" do
      assert {:error, %{type: :parse_error, message: message}} =
               Cobblestone.get_at_path(@sample, ".store.book[")

      assert String.contains?(message, "Unexpected token")
    end

    test "returns structured errors for invalid characters" do
      assert {:error, %{type: :lexer_error}} =
               Cobblestone.get_at_path(@sample, ".store.book@")
    end

    test "get_at_path!/2 raises on error" do
      assert_raise ArgumentError, fn ->
        Cobblestone.get_at_path!(@sample, ".store.book[")
      end
    end

    test "supports atom keys in maps" do
      atom_data = %{
        store: %{
          book: [
            %{title: "Elixir in Action", price: 30.0},
            %{title: "Programming Phoenix", price: 35.0}
          ]
        }
      }

      assert [%{title: "Elixir in Action", price: 30.0}, %{title: "Programming Phoenix", price: 35.0}] ==
               Cobblestone.get_at_path!(atom_data, ".store.book")

      assert ["Elixir in Action", "Programming Phoenix"] ==
               Cobblestone.get_at_path!(atom_data, ".store.book[].title")
    end

    test "supports mixed string and atom keys" do
      mixed_data = %{
        "store" => %{
          book: [
            %{"price" => 25.0, title: "Book 1"}
          ]
        }
      }

      assert [%{"price" => 25.0, title: "Book 1"}] ==
               Cobblestone.get_at_path!(mixed_data, ".store.book")

      assert ["Book 1"] ==
               Cobblestone.get_at_path!(mixed_data, ".store.book[].title")

      assert [25.0] ==
               Cobblestone.get_at_path!(mixed_data, ".store.book[].price")
    end

    test "supports pipeline-friendly at/1 function" do
      query = Cobblestone.at(".store.bicycle.color")
      assert {:ok, "red"} == query.(@sample)

      get_color = Cobblestone.at(".store.bicycle.color")
      assert {:ok, "red"} == @sample |> get_color.()
    end

    test "supports pipeline-friendly at!/1 function" do
      get_color = Cobblestone.at!(".store.bicycle.color")
      assert "red" == @sample |> get_color.()
      get_authors = Cobblestone.at!("..author")

      assert ["Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"] ==
               @sample |> get_authors.()
    end

    test "extract/2 extracts multiple paths" do
      result =
        Cobblestone.extract(@sample, %{
          color: ".store.bicycle.color",
          price: ".store.bicycle.price",
          titles: ".store.book[].title"
        })

      assert {:ok,
              %{
                color: "red",
                price: 19.95,
                titles: ["Sayings of the Century", "Sword of Honour", "Moby Dick", "The Lord of the Rings"]
              }} == result
    end

    test "extract!/2 extracts multiple paths and raises on error" do
      result =
        Cobblestone.extract!(@sample, %{
          color: ".store.bicycle.color",
          authors: "..author"
        })

      assert %{
               color: "red",
               authors: ["Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien"]
             } == result
    end
  end
end
