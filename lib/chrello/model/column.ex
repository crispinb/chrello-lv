defmodule Chrello.Model.Column do
  @moduledoc false

  @enforce_keys [:id, :name]
  defstruct [:id, :name, :cards]
  @type t :: %__MODULE__{id: integer(), name: String.t(), cards: list(Chrello.Model.Card.t())}

  def new(%{"id" => id, "name" => name}) do
    %__MODULE__{id: id, name: name}
  end
end
