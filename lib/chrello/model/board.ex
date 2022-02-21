defmodule Chrello.Model.Board do
  @moduledoc false

  alias Chrello.Model.Column
  @enforce_keys [:id, :name, :item_count]
  defstruct [:id, :name, :item_count, :columns]

  @type t :: %__MODULE__{
          id: integer,
          name: String.t(),
          item_count: integer(),
          columns: [Column.t()]
        }

  def new(%{"id" => id, "name" => name, "item_count" => item_count}) do
    %__MODULE__{id: id, name: name, item_count: item_count}
  end
end
