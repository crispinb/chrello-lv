defmodule Chrello.Board.Column do
  @enforce_keys [:id, :name]
  defstruct [:id, :name, :cards]
  @type t :: %__MODULE__{id: integer(), name: String.t(), cards: list(Chrello.Board.Card.t())}

  def new(%{"id" => id, "name" => name}) do
    %__MODULE__{id: id, name: name}
  end
end
