defmodule Board do
  @moduledoc """
  The game board, contains each player's units and the cards in play
  """

  @width 5
  @height 5

  def get_width do @width end
  def get_height do @height end

  defstruct [:units, :cards]

  @doc """
  Translates a coordinate from one players perspective to another's

  examples: 
  iex> Board.translate_coords({4,1})
  {:ok, {1,4}}

  Any invalid coordinates (outside of the board) return {:error, :invalid_coord}

  iex> Board.translate_coords({-4,1})
  {:error, :invalid_coord}

  """
  def translate_coords({x,y}) do
    cond do
      x >= @width -> {:error, :invalid_coord}
      y >= @height -> {:error, :invalid_coord}
      x < 0 -> {:error, :invalid_coord}
      y < 0 -> {:error, :invalid_coord}
      true -> {:ok, {@width - x - 1, @height - y - 1}}
    end
  end
end
