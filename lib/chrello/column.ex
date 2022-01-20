defmodule Chrello.Column do
  defstruct id: "", title: "", cards: []
  @type t :: %__MODULE__{id: String.t(), title: String.t(), cards: list(Chrello.Card.t())}
end
