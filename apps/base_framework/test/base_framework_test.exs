defmodule BaseFrameworkTest do
  use ExUnit.Case
  doctest BaseFramework

  test "greets the world" do
    assert BaseFramework.hello() == :world
  end
end
