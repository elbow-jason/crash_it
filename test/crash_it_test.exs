defmodule CrashItTest do
  use ExUnit.Case
  doctest CrashIt

  test "greets the world" do
    assert CrashIt.hello() == :world
  end
end
