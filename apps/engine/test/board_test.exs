defmodule BoardTest do
  use ExUnit.Case
  doctest Board

  test "Errors when an out of board value is entered" do
    assert {:error, :invalid_coord} = Board.translate_coords({4,-1})
    assert {:error, :invalid_coord} = Board.translate_coords({-1,4})
    assert {:error, :invalid_coord} = Board.translate_coords({5,1})
    assert {:error, :invalid_coord} = Board.translate_coords({1,5})
  end

  test "Tests correct value is returned when we entere correct data" do
    assert {:ok, {0, 0}} = Board.translate_coords({4,4})
    assert {:ok, {0, 1}} = Board.translate_coords({4,3})

  end
end
