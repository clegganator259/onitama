import Engine
defmodule Card do
  @moduledoc """
  Documentation for Card.
  """

  defstruct [:name,:moves]

  @doc """
  Given a card, it's move index and a coord it returns the coord if the move is applied to it.

  iex> Card.apply(%Card{name: "Foo", moves: [{1,2},{2,1},{-1,-2},{-2,-1}]}, 1, {2, 3})
  {:ok, {4, 4}}

  On fail it returns invalid move

  iex> Card.apply(%Card{name: "Foo", moves: [{1,2},{2,1},{-1,-2},{-2,-1}]}, 1, {3, 3})
  {:error, :invalid_move}
  """
  def apply(card=%Card{}, move_index, {x,y}) do
    case Card.get_move(card, move_index) do
      {:error, msg} -> {:error, msg}
      {:ok, {dx, dy}} -> cond do
        Board.valid_coord?({x + dx, y + dy}) -> {:ok, {x + dx, y + dy}}
        true -> {:error, :invalid_move}
      end
    end
  end

  @doc """
  Gets a move from a card at a given index

  iex> Card.get_move(%Card{name: "Foo", moves: [{1,4},{5,6},{7,3}]}, 1)
  {:ok, {5,6}}

  if there is an index error we return move_not_found

  iex> Card.get_move(%Card{name: "Foo", moves: [{1,4},{5,6},{7,3}]}, 3)
  {:error, :move_not_found}
  """

  def get_move(%Card{name: _, moves: move_list}, move_index) do
    case Enum.at(move_list, move_index) do
      nil -> {:error, :move_not_found}
      {x,y} -> {:ok, {x,y}}
    end
  end
end
