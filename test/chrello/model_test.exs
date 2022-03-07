defmodule Chrello.ModelTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Chrello.Model.{Board, Card}

  # tests of functions converting between model & checkvist API format
  # No need for any indirection here. We're never going to pair the model
  # with a different back end, so Model can handle the conversions

  test "board from checkvist List json" do
    list = Chrello.TestData.Load.list()
    tasks = Chrello.TestData.Load.tasks()
    cards = Card.get_cards_from_task_list(Jason.decode!(tasks))
    board = Board.new(Jason.decode!(list), cards)

    assert(board.id == 774_394)
    assert(board.name == "devtest")
    assert(board.current_path == [])
    assert(is_map(board.cards))
    nested_card = board.cards[1].children[0]
    assert(is_struct(nested_card))
    assert(nested_card.title == "task2.1")
  end

  test "card tree from 'tasks.json'" do
    tasks = Chrello.TestData.Load.tasks()
    card_tree = Card.get_cards_from_task_list(Jason.decode!(tasks))

    assert(is_map(card_tree))
    # 3 cards @ top level
    assert(Enum.count(card_tree) == 3)
    assert(is_struct(card_tree[0], Card))
    assert(card_tree[0].title == "task1")
    # Task 1 should be a leaf node
    task1_children = card_tree[0].children
    assert(is_map(task1_children))
    assert(Enum.empty?(task1_children))
    task3_children = card_tree[2].children
    assert(Enum.count(task3_children) == 3)
    task3_3_1_children = task3_children[2].children[0].children
    assert(Enum.count(task3_3_1_children) == 2)
    assert(task3_3_1_children[0].title == "task 3.3.1.1")
  end

  # TODO: then retrofit client & client_test

  # test "change card text"

  # test "change card position (within parent)"

  # test "change card parent (up)"

  # test "change card parent (down)"
end
