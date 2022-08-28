defmodule CobblestoneTest do
  use ExUnit.Case
  doctest Cobblestone

  test "greets the world" do
    assert Cobblestone.hello() == :world
  end
end
