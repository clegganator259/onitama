defmodule Board do
  @moduledoc """
  The game board, contains each player's units and the cards in play
  """

  @width 5
  @height 5

  def get_width do @width end
  def get_height do @height end

  defstruct [:units, :cards, :turn]

  def new(cards=[c1, c2, c3, c4, c5]) do
    Board.new(cards, nil)
    # %Board{units: {red: Board.start_position, blue: Board.start_position}, cards: {red: {c1, c2}, blue: {c3,c4} float: c5}}
  end

  def new([c1, c2, c3, c4, c5], player) do
    %Board{
      turn: player,
      units: %{
        red: Board.start_position, blue: Board.start_position
      },
      cards: %{
        red: [c1, c2], blue: [c3,c4], float: c5
      }
    }
  end

  def start_position do
    %{
      {0, 0} => :student,
      {1,0} => :student,
      {2,0} => :master,
      {3, 0} => :student,
      {4,0} => :student
    }
  end

  @doc """
  Returns a player's opponent

  examples:
  iex> Board.opponent(:red)
  :blue

  iex> Board.opponent(:blue)
  :red
  """
  def opponent(:red) do
    :blue
  end
  def opponent(:blue) do
    :red
  end

  @doc """
  Checks if a given player has won. A player has won if:

  * The player's master is on the opponent's master's starting tile
  * The opponent has not got a master

  examples

  No victor
  iex> Board.victory?(:red, Board.new([nil,nil,nil,nil,nil]))
  false

  iex> Board.victory?(:red, %Board{units: %{red: %{{2,4} => :master}, blue: %{{1,1} => :master}}})
  true

  iex> Board.victory?(:red, %Board{units: %{red: %{{1,1} => :master}, blue: %{{1,1} => :student}}})
  true

  """
  def victory?(player, %Board{units: units}) do
    opponent = Board.opponent(player)
    %{^player => friendly_units, ^opponent => enemy_units} = units
    case friendly_units do
      %{{2,4} => :master} -> true
      %{} -> Map.values(enemy_units) |> Enum.member?(:master) |> Kernel.not
    end
  end

  @doc """
  Removes any taken pieces from the board invalid boards return an error

  examples:

  iex> Board.remove_taken_pieces({:ok, %Board{units: %{red: %{{1,1} => :student}, blue: %{{3,3} => :student}}}}, :red)
  {:ok, %Board{units: %{red: %{{1,1} => :student}, blue: %{}}}}

  iex> Board.remove_taken_pieces({:ok, %Board{units: %{red: %{{1,1} => :student}, blue: %{{2,2} => :student}}}}, :red)
  {:ok, %Board{units: %{red: %{{1,1} => :student}, blue: %{{2,2} => :student}}}}
  """
  def remove_taken_pieces({:ok, board=%Board{units: units}}, player)  do
    opponent = Board.opponent(player)
    %{^player => friendly_units, ^opponent => enemy_units} = units
    resulting_units = enemy_units |> Enum.filter(
      fn
        {k, _} -> friendly_units
        |> Map.has_key?(
          case Board.translate_coords(k) do
            {:ok, coords} -> coords
          end
        ) |> Kernel.not
      end
    ) |> Map.new # Result is a list if we don't convert it back to a map
    {:ok, %{board | units: %{player => friendly_units, opponent => resulting_units}}}
  end

  def remove_taken_pieces(_,{:error, msg}) do
    {:error, msg}
  end

  @doc """
  Translates a coordinate from one players perspective to another's

  examples:
  iex> Board.translate_coords({4,1})
  {:ok, {0,3}}

  Any invalid coordinates (outside of the board) return {:error, :invalid_coord}

  iex> Board.translate_coords({-4,1})
  {:error, :invalid_coord}

  """
  def translate_coords({x,y}) do
    cond do
      valid_coord?({x, y}) -> {:ok, {@width - x - 1, @height - y - 1}}
      true -> {:error, :invalid_coord}
    end
  end

  @doc """
  Checks if a coord is within the bounds of the board

  iex> Board.valid_coord?({0,0})
  true

  iex> Board.valid_coord?({4,4})
  true

  iex> Board.valid_coord?({1,2})
  true

  iex> Board.valid_coord?({-1,-1})
  false

  iex> Board.valid_coord?({5, 5})
  false
  """
  def valid_coord?({x,y}) do
    cond do
      x >= @width -> false
      y >= @height -> false
      x < 0 -> false
      y < 0 -> false
      true -> true
    end
  end

  def has_card?(board = %Board{cards: cards}, card = %Card{}, player)do
    %{^player => friendly_cards} = cards
    cards |> Enum.member?(card)
  end

  @doc """
  Checks to see if a player has a piece at a given position

  iex> Board.has_piece?(%Board{units: %{red: %{{2,1} => :student }}}, :red, {2,1})
  true

  iex> Board.has_piece?(%Board{units: %{red: %{{2,1} => :student }}}, :red, {3,1})
  false
  """
  def has_piece?(board = %Board{units: units}, player, coord) do
    %{^player => friendly_units} = units
    friendly_units |> Map.has_key?(coord)
  end

  @doc """
  Checks if all of the positions on the board are valid

  examples:

  iex> Board.valid_board?(Board.new([1,2,3,4,5]))
  true

  iex> Board.valid_board?(%Board{units: %{red: %{{-1, -1} => :student}, blue: %{{1,1} => :student}}})
  false
  """
  def valid_board?(%Board{units: %{red: red_units, blue: blue_units}}) do
    Enum.all?(red_units, fn {k,_} -> valid_coord?(k) end) and
    Enum.all?(blue_units, fn {k,_} -> valid_coord?(k) end)
  end

  @doc """
  Moves a piece from a given coord to it's new coord

  Examples
  iex> Board.move_piece(%Board{units: %{red: %{{1,2} => :student}}}, :red, {1,2}, {2,4})
  {:ok, %Board{units: %{red: %{{2,4} => :student}}}}
  """
  def move_piece(board = %Board{units: units}, player, start_coord, new_coord) do
    pieces = units |> Map.get(player)
    piece = pieces |> Map.get(start_coord)
    existing_piece = pieces |> Map.get(new_coord)
    if piece != nil and existing_piece == nil do
      new_pieces = pieces |> Map.delete(start_coord) |> Map.put(new_coord, piece)
      {:ok, %{ board  | units: Map.put(board.units, player, new_pieces)}}
    else
      {:error, "Something went wrong"}
    end
  end

  @doc """
  Rotates the cards at the end of the round to put the new card in the player's hand and the played card in the float

  Examples:
  iex> Board.rotate_cards({:ok, Board.new([:c1, :c2, :c3, :c4, :c5])}, :red, :c1)
  {:ok, %Board{units: %{red: Board.start_position(), blue: Board.start_position()}, cards: %{red: [:c5, :c2], blue: [:c3, :c4], float: :c1}}}
  """
  def rotate_cards({:ok, board=%Board{cards: cards}}, player, card) do
    friendly_cards = cards
      |> Map.get(player)
      |> List.delete(card)
      |> (&([cards.float | &1])).()
    rotated_cards = cards
      |> Map.put(player, friendly_cards )
      |> Map.put(:float, card)
    {:ok, %{board | cards: rotated_cards}}
  end

  @doc """
  Switches the player who's turn it is

  Example:
  iex> Board.switch_player({:ok, %Board{turn: :red}})
  {:ok, %Board{turn: :blue}}
  """
  def switch_player({:ok, board}) do
    {:ok, Map.update!(board, :turn, &Board.opponent/1)}
  end
end

