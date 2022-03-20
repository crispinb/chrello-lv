defmodule Chrello.Util.ListUtil do

  @doc """
  Moves a list item within a list from one position to another, leaving no gaps
  """
  @spec move_item(list(), pos_integer(), pos_integer()) :: list()
  def move_item(list, from, to) do
    to_item = Enum.at(list, to)

    list
    |> List.replace_at(to, Enum.at(list, from))
    |> List.replace_at(from, to_item)
  end

  @doc """
  Moves an item from one list to a specific position in another list,
  returning both updated lists s
  """
  @spec move_item_to_list(list(), pos_integer(), list(), pos_integer()) :: {list(), list()}
  def move_item_to_list(from_list, from_index, to_list, to_index) do
    {card_to_move, updated_from_list} = List.pop_at(from_list, from_index)

    updated_to_list = List.insert_at(to_list, to_index, card_to_move)
    {updated_from_list, updated_to_list}
  end

end
