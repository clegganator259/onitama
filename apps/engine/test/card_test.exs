defmodule CardTest do
  use ExUnit.Case
  doctest Card
  test "Tests a card can be applied correctly" do
    assert {:ok, {3 ,4}} = Card.apply(%Card{name: "test", moves: [{1,2}, {2,-1}]}, 0, {2,2})
    assert {:ok, {0 ,1}} = Card.apply(%Card{name: "test", moves: [{1,2}, {-2,-1}]}, 1, {2,2})
  end

  test "Tests a card fails on invalid coord" do
    assert {:error, :invalid_move} = Card.apply(%Card{name: "test", moves: [{1,2}, {2,-1}]}, 0, {4,3})
    assert {:error, :invalid_move} = Card.apply(%Card{name: "test", moves: [{1,2}, {-2,-1}]}, 1, {0,0})
  end

end
