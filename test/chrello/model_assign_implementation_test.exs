defmodule Chrello.ModelAssignImplementationTest do
  @moduledoc """
  Tests of Assign behaviour implementations for Card and Board
  """
  use ExUnit.Case, async: true

  alias Chrello.Model.{Card, Board}

  setup do
    tasks = Chrello.TestData.Load.tasks()
    cards = Card.get_cards_from_task_list(Jason.decode!(tasks))
    list = Chrello.TestData.Load.list()
    board = Board.new(Jason.decode!(list), cards)
    %{board: board, cards: cards}
  end

  describe "Card" do
    test "get 1 level", %{cards: cards} do
      card2 = Enum.at(cards, 1)
      card2_child1 = card2[0]
      # syntaxes for Access? Kernel.get_in, [], Access methods?
      assert(is_struct(card2_child1, Card))
      assert(card2_child1.content == "task2.1")
    end

    test "Get nested card", %{cards: cards} do
      card3 = Enum.at(cards, 2)
      nested_card = get_in(card3, [2, 0, 0])

      assert(nested_card.content == "task 3.3.1.1")
    end

    test "Get property within nested card", %{cards: cards} do
      card3 = Enum.at(cards, 2)

      assert(get_in(card3, [2, 0, 0, :title]) == "task 3.3.1.1")
    end

    test "Pop cards", %{cards: cards} do
      card2 = Enum.at(cards, 1)

      assert(card2.title == "task2")
      assert(length(card2.children) == 2)
      {card2_1, rest} = pop_in(card2, [0])
      assert(card2_1.title == "task2.1")
      assert(length(rest) == 1)
    end

    test "Get and update cards", %{cards: cards} do
      card2 = Enum.at(cards, 1)
      card2_1 = get_in(card2, [0])
      card2_2 = get_in(card2, [1])

      # ie replace 2_2 with 2_1
      {old_value, updated_card} = get_and_update_in(card2, [1], fn card -> {card, card2_1} end)
      assert(old_value == card2_2)
      assert(Enum.at(updated_card.children, 0) == Enum.at(updated_card.children, 1))
    end
  end

  describe "Board" do
    test "access 1 level", %{board: board} do
      card1 = board[0]

      assert(is_struct(card1, Card))
      assert(card1.content == "task1")
    end

    test "access nested", %{board: board} do
      nested_card = get_in(board, [2, 2, 0, 0])

      assert(nested_card.content == "task 3.3.1.1")
    end

    test "access property within nested", %{board: board} do
      assert(get_in(board, [2, 2, 0, 0, :content]) == "task 3.3.1.1")
    end

    test "get and update", %{board: board} do
      card2_2 = get_in(board, [1, 1])

      {_original2_2, updated_board} =
        get_and_update_in(board, [1, 0], fn card -> {card, card2_2} end)

      assert(get_in(updated_board, [1, 0]) == get_in(board, [1, 1]))
    end
  end
end
