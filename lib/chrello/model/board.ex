defmodule Chrello.Model.Board do
  @moduledoc """
  :card is a map of integers (representing positions) to cards
  %{1 => card1, 2 => card2}
  Cards are a nested struct, with each having "children" member
  pointing to another (possibly empty) integer-keyed map.

  'current_path' is a list of integers. It determines which part of the card tree will be represented as columns, ie.  'zoom' level of the board. The current path is always empty on Board creation.

  If the current path is empty, each :card item represents the position and data of a column  - eg in the above, 'card1' and 'card2' provide the data for the first and 2nd columns respectively. The columns' cards then come from these cards '.children. property. eg.  Column 1's card data are provided by card1.children (each of which is a position => card mapping)
  """

  alias Chrello.Model.Card

  @enforce_keys [:id, :name, :item_count, :cards]
  defstruct [:id, :name, :item_count, :cards, current_path: []]

  @type t :: %__MODULE__{
          id: integer,
          name: String.t(),
          item_count: integer(),
          cards: %{integer() => Card.t()},
          current_path: list(integer())
        }

  @spec new(%{String.t() => integer(), String.t() => String.t(), String.t() => integer()}, %{
          integer() => Card.t()
        }) :: __MODULE__.t()
  def new(%{"id" => id, "name" => name, "item_count" => item_count}, %{} = cards) do
    %__MODULE__{id: id, name: name, item_count: item_count, cards: cards}
  end
end
