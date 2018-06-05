defmodule BoardTest do
  use ExUnit.Case
  doctest Board

  test "Errors when translating coords and y is negative" do
    assert {:error, :invalid_coord} = Board.translate_coords({4,-1})
  end
  test "Errors when translating coords x is negative" do
    assert {:error, :invalid_coord} = Board.translate_coords({-1,4})
  end
  test "Errors when translating coords x is too big" do
    assert {:error, :invalid_coord} = Board.translate_coords({5,1})
  end
  test "Errors when translating coords y is too big" do
    assert {:error, :invalid_coord} = Board.translate_coords({1,5})
  end

  test "Valid coords works for correct values" do
    for x <- 1..Board.get_width - 1 , y <- 0..Board.get_height - 1, do:
      assert true = Board.valid_coord?({x, y})
  end

  test "Returns false when translating coords and y is negative" do
    assert Board.valid_coord?({4,-1}) == false 
  end
  test "Returns false when translating coords x is negative" do
    assert Board.valid_coord?({-1,4}) == false
  end
  test "Returns false when translating coords x is too big" do
    assert  Board.valid_coord?({5,1}) == false
  end
  test "Returns false when translating coords y is too big" do
    assert Board.valid_coord?({1,5}) == false
  end

  test "Tests correct value is returned when we entere correct data" do
    assert {:ok, {0, 0}} = Board.translate_coords({4,4})
    assert {:ok, {0, 1}} = Board.translate_coords({4,3})
  end
end
