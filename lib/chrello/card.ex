defmodule Chrello.Card do
  defstruct id: "", title: "", body: ""
  @type t :: %__MODULE__{id: String.t(), title: String.t(), body: String.t()}
end
