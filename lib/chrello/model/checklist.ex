defmodule Chrello.Model.Checklist do
  @moduledoc """

  Struct modelling a Checkvist list. Functions in this module operate on Checklist, which it is an opaque type intended to be consumed by clients via `board`

  .tasks is a list of Task structs. Tasks are nested, with each having a "children" member consisting of another (possibly empty) list of tasks

  'current_path' is an Access path to a Task whose children will be the root list for a board returned by `board/1`. Each top-level task in the root list is a column of the returned board.

  If the current path is empty (the default), each .tasks item represents the position and data of a column. Each columns' tasks then comes from its `.children` property

  The `board` type represents a columnar view of the underlying checklist, reflecting the checklist's current 'zoom' level (ie. the board's columns are the children of the checklist task pointed to by `current_path`)

  """

  @behaviour Access
  alias Chrello.Model.Task
  alias Chrello.Util.ListUtil

  # TODO: consider removin item_count (redundant, and we don't use it)
  @enforce_keys [:id, :name, :item_count, :tasks]
  defstruct [:id, :name, :item_count, :tasks, current_path: []]

  @opaque t :: %__MODULE__{
            id: integer,
            name: String.t(),
            item_count: integer(),
            tasks: list(Task.t()),
            current_path: list(integer())
          }

  @type board :: %{
          id: integer,
          name: String.t(),
          columns: list(Task.t())
        }

  # TODO: a similar external type for Tasks?
  # TODO: conform & validate with Ecto.Changeset?
  # TODO: add test with nil or bad params to .new
  # TODO: list all the means of checking for nil.
  #       pattern-matching, guards, explicit checks, changesets?
  # here, id and name shoulnd't be nullable. Netiher current_path.
  # also, what about updating properties to nil?
  @spec new(
          %{String.t() => integer(), String.t() => String.t(), String.t() => integer()},
          list(Task.t())
        ) :: __MODULE__.t()
  def new(%{"id" => id, "name" => name, "item_count" => item_count}, tasks) do
    %__MODULE__{id: id, name: name, item_count: item_count, tasks: tasks}
  end

  @spec board(__MODULE__.t()) :: __MODULE__.board()
  def board(%__MODULE__{current_path: []} = checklist) do
    %{id: checklist.id, name: checklist.name, columns: checklist.tasks}
  end

  def board(%__MODULE__{} = checklist) do
    root_task = get_in(checklist, checklist.current_path)
    breadcrumbs = board_breadcrumbs(checklist)

    name =
      breadcrumbs
      |> Enum.reduce("", fn crumb, acc -> acc <> "/" <> crumb.name end)

    %{id: checklist.id, name: name, columns: root_task.children}
  end

  # eg boardname / subtask3_title / subtask3.1_title
  defp board_breadcrumbs(%__MODULE__{} = checklist) do
    crumbs_acc =
      checklist.current_path
      |> Enum.map_reduce([], fn path_segment, path ->
        path = path ++ [path_segment]
        task = get_in(checklist, path)
        # TODO: nil out the map if task nil?
        {%{name: task.title}, path}
      end)

    # add parent checklist to breadcrumb head
    [%{name: checklist.name} | elem(crumbs_acc, 0)]
  end

  # TODO: convert to reduction?
  # searches the checklist tree (checklist.tasks plus all task children)
  # for a task with task_id, returning an Access-style path to the task
  # or the empty list if not found
  def path_to_task(%__MODULE__{} = checklist, task_id) do
    if found_id = Enum.find_index(checklist.tasks, &(&1.id == task_id)) do
      [found_id]
    else
      path_to_task(checklist.tasks, [], task_id)
    end
  end

  def path_to_task([], acc, _task_id) do
    IO.inspect([], label: :BASE_CASE)
    acc
  end

  def path_to_task([task | rest] = temp, acc, task_id) do
    IO.inspect(temp, label: :DERIVED_CASE)

    if found_id = Enum.find_index(task.children, &(&1.id == task_id)) do
      IO.inspect(found_id, label: :FOUND)
      acc ++ [found_id]
    else
      acc ++ path_to_task(rest, acc, task_id)
    end
  end

  def zoom_to_task_multi(checklist, task_id) do
  end

  @doc """
  If task_id is one of the checklist's top-level tasks,
  set current_path to point to it.
  Otherwise ignore
  """
  def zoom_to_task(checklist, task_id) do
    tasks =
      if Enum.empty?(checklist.current_path),
        do: checklist.tasks,
        else: get_in(checklist, checklist.current_path).children

    path_segment =
      for {task, index} <- Enum.with_index(tasks), task.id == task_id do
        if task.id == task_id, do: index
      end

    %{checklist | current_path: checklist.current_path ++ path_segment}
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
