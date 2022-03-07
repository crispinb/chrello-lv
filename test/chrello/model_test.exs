defmodule Chrello.ModelTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Chrello.Model.{Board, Card}

  # tests of functions converting between model & checkvist API format
  # No need for any indirection here. We're never going to pair the model
  # with a different back end, so Model can handle the conversions

  setup do
    list = Chrello.TestData.Load.list()
    tasks = Chrello.TestData.Load.tasks()
    cards = Card.get_cards_from_task_list(Jason.decode!(tasks))
    board = Board.new(Jason.decode!(list), cards)
    %{cards: cards, board: board}
  end

  test "get card tree from 'tasks.json'", %{cards: cards} do
    # 3 cards @ top level
    [card1 | [_ | [card3 | _]]] = cards

    assert(is_list(cards))
    assert(length(cards) == 3)
    assert(is_struct(card1, Card))
    assert(card1.title == "task1")

    assert(is_list(card1.children))
    assert(Enum.empty?(card1.children))
    assert(length(card3.children) == 3)

    card3_3_1 = get_in(card3, [2, 0])
    assert(length(card3_3_1.children) == 2)
    card3_3_1_1 = card3_3_1[0]
    assert(card3_3_1_1.title == "task 3.3.1.1")
  end

  test "get board from checkvist List json", %{board: board} do
    assert(board.id == 774_394)
    assert(board.name == "devtest")
    assert(board.current_path == [])
    assert(is_list(board.cards))

    nested_card = get_in(board, [1, 0])

    assert(is_struct(nested_card))
    assert(nested_card.title == "task2.1")
  end

  test "move card (at board top level)", %{board: board} do
    board_updated = Board.move(board, [0], [1])

    assert(Enum.count(board.cards) == Enum.count(board_updated.cards))
    assert(board_updated[0].id == board[1].id)
    assert(board_updated[1].id == board[0].id)
  end

  test "move card (withiin same nested card's children)", %{board: board} do
    board_updated = Board.move(board, [1, 0], [1, 1])

    assert(board_updated != board)
    assert(Enum.count(board.cards) == Enum.count(board_updated.cards))
    assert(get_in(board_updated, [1, 0]).id == get_in(board, [1, 1]).id)
  end

  test "move card (between nested cards' children)", %{board: board} do
    board_updated = Board.move(board, [1, 0], [0, 0])

    assert(board_updated != board)
    assert(Enum.count(board.cards) == Enum.count(board_updated.cards))
    assert(length(get_in(board_updated, [0]).children) == 1)
    assert(length(board_updated[1][:children]) == 1)
    assert(get_in(board_updated, [0, 0]) == get_in(board, [1, 0]))
  end

  # test "change card contents"
end
