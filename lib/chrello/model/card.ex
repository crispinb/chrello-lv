defmodule Chrello.Model.Card do
  @moduledoc """
  Card struct + functions to convert from Checkvist JSON
  Tightly coupled to Checkvist as this will never use a
  different backend
  """

  defstruct id: "", title: "", content: "", children: %{}

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          content: String.t(),
          children: Card.t()
        }

  alias Chrello.Util.MapUtil

  # TODO: deal with notes

  @spec new(map) :: __MODULE__.t()
  def new(%{"id" => id, "content" => content, "children" => %{} = children}) do
    # TODO: summarise? (api/library, or just pick first n chars/words)
    title = Enum.join(Enum.take(String.split(content), 3), " ")

    children =
      children
      |> Enum.map(fn {k, v} -> {k, __MODULE__.new(v)} end)
      |> Enum.into(%{})

    %__MODULE__{id: id, content: content, title: title, children: children}
  end

  def new(%{"id" => id, "content" => content}) do
    __MODULE__.new(%{"id" => id, "content" => content, "children" => %{}})
  end

  @spec get_cards_from_task_list(list) :: map()
  @doc """
    From Checkvist's flat json list of tasks, create a map from
    position (number) to either a task (if it's leaf) or to
    another map (if there are subtasks)
  """
  def get_cards_from_task_list(tasks_json) do
    parent_ids =
      tasks_json
      |> Enum.filter(fn task -> task["parent_id"] == 0 end)
      |> Enum.map(fn task -> task["id"] end)

    tasks_json
    |> MapUtil.unflatten(parent_ids, "id", "tasks", "children")
    |> MapUtil.index_list_of_maps_by_key_recursive("position", "children")
    |> Enum.map(fn {k, v} -> {k, __MODULE__.new(v)} end)
    |> Enum.into(%{})
  end

end
