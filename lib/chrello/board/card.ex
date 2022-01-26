defmodule Chrello.Board.Card do
  defstruct id: "", title: "", content: ""
  @type t :: %__MODULE__{id: String.t(), title: String.t(), content: String.t()}

  # TODO: deal with notes

  def new(%{"id" => id, "content" => content}) do
    # TODO: summarise? (must be an api I can use)
    title = Enum.join(Enum.take(String.split(content), 3), " ")
    %__MODULE__{id: id, content: content, title: title}
  end
end
