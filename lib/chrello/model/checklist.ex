defmodule Chrello.Model.Checklist do
  @moduledoc """
  :tasks is a list of Task structs
  Tasks are nested structs, with each having "children" member
  pointing to another (possibly empty) list of tasks

  'current_path' is a list of integers. It points to a children value which will be the current root list. Each task in the root list can be represented as a column in the UI, with the children list containing that column's tasks. The current path is always empty on Board creation.

  If the current path is empty, each :task item represents the position and data of a column  - eg in the above, 'task1' and 'task2' provide the data for the first and 2nd columns respectively. The columns' tasks then come from these tasks '.children. property. eg.  Column 1's task data are provided by task1.children (each of which is a position => task mapping)
  """
  @behaviour Access
  alias Chrello.Model.Task
  alias Chrello.Util.ListUtil

  @enforce_keys [:id, :name, :item_count, :tasks]
  defstruct [:id, :name, :item_count, :tasks, current_path: []]

  @opaque t :: %__MODULE__{
            id: integer,
            name: String.t(),
            item_count: integer(),
            tasks: list(Task.t()),
            current_path: list(integer())
          }

  # TODO: a similar external type for Tasks?
  @type board :: %{
          id: integer,
          name: String.t(),
          cards: list(Task.t())
        }

# TODO: use an Ecto.Changeset?
  @spec new(
          %{String.t() => integer(), String.t() => String.t(), String.t() => integer()},
          list(Task.t())
        ) :: __MODULE__.t()
  def new(%{"id" => id, "name" => name, "item_count" => item_count}, tasks) do
    %__MODULE__{id: id, name: name, item_count: item_count, tasks: tasks}
  end

  @spec board(__MODULE__.t()) :: __MODULE__.board()
  def board(checklist) do
    %{id: checklist.id, name: checklist.name, cards: checklist.tasks}
  end

  @doc """
  Move task from one position to another within the checklist.

  "From" and "To" positions are indicated by Access-style paths, eg [0, 1] in board b is:
  `b.tasks[0].tasks[1]`

  """
  @spec move(t(), list(integer()), list(integer())) :: __MODULE__.t()
  # top-level move (path contains just 1 index)
  def move(checklist, [from_index], [to_index]) do
    %{checklist | tasks: ListUtil.move_item(checklist.tasks, from_index, to_index)}
  end

  # nested move (either path has more than 1 indices)
  def move(checklist, from_path, to_path) do
    [from | from_parent_path] = Enum.reverse(from_path)
    [to | to_parent_path] = Enum.reverse(to_path)

    move_item(
      checklist,
      from_parent_path,
      to_parent_path,
      from,
      to
    )
  end

  # move within child lists
  defp move_item(checklist, _from_path = path, _to_path = path, from, to) do
    parent_task = get_in(checklist, path)
    updated_children = ListUtil.move_item(parent_task[:children], from, to)
    updated_parent_task = %{parent_task | children: updated_children}
    put_in(checklist, path, updated_parent_task)
  end

  # move between child lists
  defp move_item(checklist, from_path, to_path, from, to) do
    from_parent_task = get_in(checklist, from_path)
    to_parent_task = get_in(checklist, to_path)

    {updated_from_children, updated_to_children} =
      ListUtil.move_item_to_list(
        from_parent_task[:children],
        from,
        to_parent_task[:children],
        to
      )

    updated_from_parent_task = %{from_parent_task | children: updated_from_children}
    updated_to_parent_task = %{to_parent_task | children: updated_to_children}

    checklist
    |> put_in(from_path, updated_from_parent_task)
    |> put_in(to_path, updated_to_parent_task)
  end

  # Access
  @impl Access
  def fetch(checklist, key) do
    case Enum.at(checklist.tasks, key) do
      nil -> :error
      value -> {:ok, value}
    end
  end

  @impl Access
  def get_and_update(checklist, key, function) do
    value = Access.get(checklist, key)

    tasks =
      case function.(value) do
        {_value, new_value} -> List.replace_at(checklist.tasks, key, new_value)
        :pop -> List.delete_at(checklist.tasks, key)
      end

    {value, %{checklist | tasks: tasks}}
  end

  @impl Access
  def pop(checklist, key) do
    List.pop_at(checklist.tasks, key)
  end
end
