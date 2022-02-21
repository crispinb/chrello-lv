defmodule Chrello.ModelTest do
  use ExUnit.Case, async: true
  alias Chrello.Model.{Board, Card}

  # tests of functions converting between model & checkvist API format
  # No need for any indirection here. We're never going to pair the model
  # with a different back end

  # probably remove this test
  test "board from checkvist List json" do
    list = Chrello.TestData.Load.list()
    board = Board.new(Jason.decode!(list))

    assert(board.id == 774_394)
    assert(board.name == "devtest")
    assert(board.item_count == 5)
  end

  test "card tree from 'tasks.json'" do
    tasks = Chrello.TestData.Load.tasks()
    card_tree = Card.get_cards_from_task_list(Jason.decode!(tasks))


    assert(is_map(card_tree))
    # 3 cards @ top level
    assert(Enum.count(card_tree) == 3)
    assert(is_struct(card_tree[1], Card))
    assert(card_tree[1].title == "task1")
    # Task 1 should be a leaf node
    task1_children = card_tree[1].children
    assert(is_map(task1_children))
    assert(Enum.count(task1_children) == 0)
    task3_children = card_tree[3].children
    assert(Enum.count(task3_children) == 3)
    task3_3_1_children = task3_children[3].children[1].children
    assert(Enum.count(task3_3_1_children) == 2)
    assert(task3_3_1_children[1].title == "task 3.3.1.1")
  end

  # 1. assemble columns from top level
  # 2 what would it take to start from next level down?
  # test "columns from checkvist 'tasks.json'" do
  # end

  # test "card from checkvist 'taskNNN.json'"

  # test "change card text"

  # test "change card position (within parent)"

  # test "change card parent (up)"

  # test "change card parent (down)"
end
