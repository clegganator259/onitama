defmodule Engine do
  @moduledoc """
  Documentation for Engine.
  """

  @doc """
  Makes a move on a board given a valid move
  """
  def make_move(board = %Board{}, player, card, index, piece_coord) do
    case Card.apply(card, index, piece_coord) do
      {:error, msg} -> {:error, msg}
      {:ok, target_coord} -> board
        |> Board.move_piece(player, piece_coord, target_coord)
        |> Board.remove_taken_pieces(player)
        |> Board.rotate_cards(player, card)
        |> Board.switch_player()
    end
  end

  def get_cards() do
    {:ok, body} = File.read("config/cards.json")
    unparsed_cards = Poison.decode!(body, as: [%Card{}])
    unparsed_cards |> Enum.map(
      fn cards -> Map.put(
        cards,
        :moves,
        Enum.map(cards.moves, &List.to_tuple/1)
      ) end
    )
  end
  def start_game() do
    cards = Engine.get_cards() |> Enum.take_random(5)
    player = Enum.random([:red, :blue])
    board = Board.new(cards, player)
  end
end
