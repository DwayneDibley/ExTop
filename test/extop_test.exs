defmodule ExtopTest do
  use ExUnit.Case
  doctest Extop

  test "greets the world" do
    assert Extop.hello() == :world
  end
end
