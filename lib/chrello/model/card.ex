defmodule Chrello.Model.Card do
  @moduledoc """
  Card struct + functions to convert from Checkvist JSON
  Tightly coupled to Checkvist as this will never use a
  different backend
  """

  defstruct id: "", title: "", content: "", children: []

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          content: String.t(),
          children: list(__MODULE__.t())
        }

  @behaviour Access

  alias Chrello.Util.MapUtil

  @spec new(map) :: __MODULE__.t()
  def new(%{"id" => id, "content" => content, "children" => children}) do
    # TODO: summarise? (api/library, or just pick first n chars/words)
    title = Enum.join(Enum.take(String.split(content), 3), " ")

    %__MODULE__{id: id, content: content, title: title, children: children}
  end

  def new(%{"id" => id, "content" => content}) do
    __MODULE__.new(%{"id" => id, "content" => content, "children" => []})
  end

  @spec get_cards_from_task_list(list) :: list(__MODULE__.t())
  @doc """
    From Checkvist's flat json list of tasks, create a tree of cards.
    The value of the 'children' key is a list of child cards
  """
  def get_cards_from_task_list(tasks_json) do
    lookup = MapUtil.index_list_of_maps_by_key(tasks_json, "id")

    tasks_json
    |> Enum.filter(fn task -> task["parent_id"] == 0 end)
    |> Enum.map(&task_to_card(&1, lookup))
  end

  defp task_to_card(%{} = task, task_lookup) do
    task = MapUtil.rename_keys(task, %{"tasks" => "children"})
    children = Enum.map(task["children"], &task_to_card(&1, task_lookup))
    __MODULE__.new(%{task | "children" => children})
  end

  defp task_to_card(task_id, task_lookup) do
    task = task_lookup[task_id]
    task_to_card(task, task_lookup)
  end

  # Access
  @impl Access

  # NB. This is incomplete for get_and_update and pop, neither of which
  # implements Access for non-integer keys

  def fetch(card, key) when is_number(key) do
    case Enum.at(card.children, key) do
      nil -> :error
      value -> {:ok, value}
    end
  end

  def fetch(card, key)  do
    {:ok, Map.get(card, key)}
  end


  @impl Access
  def get_and_update(card, key, f) do
    value = Enum.at(card.children, key)

    children =
      case f.(value) do
        {_current_value, new_value} -> List.replace_at(card.children, key, new_value)
        :pop -> List.delete_at(card.children, key)
      end

    {value, %{card | children: children}}
  end

  @impl Access
  def pop(card, key) do
    List.pop_at(card.children, key)
  end
end
