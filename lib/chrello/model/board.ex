defmodule Chrello.Model.Board do
  @moduledoc """
  :cards is a list of Card structs
  Cards are nested structs, with each having "children" member
  pointing to another (possibly empty) list of cards

  'current_path' is a list of integers. It points to a children value which will be the current root list. Each card in the root list can be represented as a column in the UI, with the children list containing that column's cards. The current path is always empty on Board creation.

  If the current path is empty, each :card item represents the position and data of a column  - eg in the above, 'card1' and 'card2' provide the data for the first and 2nd columns respectively. The columns' cards then come from these cards '.children. property. eg.  Column 1's card data are provided by card1.children (each of which is a position => card mapping)
  """
  @behaviour Access
  alias Chrello.Model.Card

  @enforce_keys [:id, :name, :item_count, :cards]
  defstruct [:id, :name, :item_count, :cards, current_path: []]

  @type t :: %__MODULE__{
          id: integer,
          name: String.t(),
          item_count: integer(),
          cards: list(Card.t()),
          current_path: list(integer())
        }

  @spec new(
          %{String.t() => integer(), String.t() => String.t(), String.t() => integer()},
          list(Card.t())
        ) :: __MODULE__.t()
  def new(%{"id" => id, "name" => name, "item_count" => item_count}, cards) do
    %__MODULE__{id: id, name: name, item_count: item_count, cards: cards}
  end

  @doc """
  Move card from one position to another within the board.

  "From" and "To" positions are indicated by Access-style paths, eg [0, 1] in board b is:
  `b.cards[0].cards[1]`

  """
  @spec move(t(), list(integer()), list(integer())) :: __MODULE__.t()
  # top-level move
  def move(board, [from_index], [to_index]) do
    %{board | cards: move_within_list(board.cards, from_index, to_index)}
  end

  def move(board, from_path, to_path) do
    from_parent_path = Enum.drop(from_path, -1)
    to_parent_path = Enum.drop(to_path, -1)

    if from_parent_path == to_parent_path do
      parent_card = get_in(board, from_parent_path)

      updated_children =
        move_within_list(
          parent_card[:children],
          hd(Enum.reverse(from_path)),
          hd(Enum.reverse(to_path))
        )

      updated_parent_card = %{parent_card | children: updated_children}
      put_in(board, from_parent_path, updated_parent_card)
    else
      from_parent_card = get_in(board, from_parent_path)
      to_parent_card = get_in(board, to_parent_path)

      {updated_from_children, updated_to_children} =
        move_between_lists(
          from_parent_card[:children],
          hd(Enum.reverse(from_path)),
          to_parent_card[:children],
          hd(Enum.reverse(to_path))
        )

      updated_from_parent_card = %{from_parent_card | children: updated_from_children}
      updated_to_parent_card = %{to_parent_card | children: updated_to_children}

      board
      |> put_in(from_parent_path, updated_from_parent_card)
      |> put_in(to_parent_path, updated_to_parent_card)
    end
  end

  # TODO: probably move this to generic
  def move_within_list(list, from, to) do
    to_item = Enum.at(list, to)

    list
    |> List.replace_at(to, Enum.at(list, from))
    |> List.replace_at(from, to_item)
  end

  def move_between_lists(from_list, from_index, to_list, to_index) do

    {card_to_move, updated_from_list} = List.pop_at(from_list, from_index)

    updated_to_list = List.insert_at(to_list, to_index, card_to_move)
    {updated_from_list, updated_to_list}
  end

  # Access
  @impl Access
  def fetch(board, key) do
    case Enum.at(board.cards, key) do
      nil -> :error
      value -> {:ok, value}
    end
  end

  @impl Access
  def get_and_update(board, key, function) do
    value = Access.get(board, key)

    cards =
      case function.(value) do
        {_value, new_value} -> List.replace_at(board.cards, key, new_value)
        :pop -> List.delete_at(board.cards, key)
      end

    {value, %{board | cards: cards}}
  end

  @impl Access
  def pop(board, key) do
    List.pop_at(board.cards, key)
  end
end
