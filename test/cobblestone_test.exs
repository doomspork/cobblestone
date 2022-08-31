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
    test "supports simple `.key` paths" do
      assert %{
               "color" => "red",
               "price" => 19.95
             } == Cobblestone.get_at_path(@sample, ".store.bicycle")

      assert "red" == Cobblestone.get_at_path(@sample, ".store.bicycle.color")
    end

    test "supports [index]" do
      assert [
               %{
                 "category" => "reference",
                 "author" => "Nigel Rees",
                 "title" => "Sayings of the Century",
                 "price" => 8.95
               }
             ] == Cobblestone.get_at_path(@sample, ".store.book[0]")
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
             ] == Cobblestone.get_at_path(@sample, ".store.book[0,2,3]")
    end

    test "supports [index:index]" do
      assert [
               %{
                 "category" => "fiction",
                 "author" => "Evelyn Waugh",
                 "title" => "Sword of Honour",
                 "price" => 12.99
               }
             ] == Cobblestone.get_at_path(@sample, ".store.book[1:2]")
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
             ] == Cobblestone.get_at_path(@sample, ".store.book[:2]")
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
             ] == Cobblestone.get_at_path(@sample, ".store.book[2:]")
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
             ] == Cobblestone.get_at_path(@sample, ".store.book[-1]")

      assert [
               %{
                 "category" => "fiction",
                 "author" => "Herman Melville",
                 "title" => "Moby Dick",
                 "isbn" => "0-553-21311-3",
                 "price" => 8.99
               }
             ] == Cobblestone.get_at_path(@sample, ".store.book[-2]")
    end
  end
end
