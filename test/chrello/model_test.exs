defmodule Chrello.ModelTest do
  @moduledoc false
  use ExUnit.Case, async: true
  # TODO: task -> Task
  alias Chrello.Model.{Checklist, Task}

  # tests of functions converting between model & checkvist API format
  # No need for any indirection here. We're never going to pair the model
  # with a different back end, so Model can handle the conversions

  setup do
    list = Chrello.TestData.Load.list()

    tasks =
      Chrello.TestData.Load.tasks()
      |> Jason.decode!()
      |> Task.get_tasks_from_task_list()

    checklist = Checklist.new(Jason.decode!(list), tasks)

    %{tasks: tasks, checklist: checklist}
  end

  test "get task tree from 'tasks.json'", %{tasks: tasks} do
    # 3 tasks @ top level
    [task1 | [_ | [task3 | _]]] = tasks

    assert(is_list(tasks))
    assert(length(tasks) == 3)
    assert(is_struct(task1, Task))
    assert(task1.title == "task1")

    assert(is_list(task1.children))
    assert(Enum.empty?(task1.children))
    assert(length(task3.children) == 3)

    task3_3_1 = task3[2][0]
    assert(length(task3_3_1.children) == 2)
    task3_3_1_1 = task3_3_1[0]
    assert(task3_3_1_1.title == "task 3.3.1.1")
  end

  test "get checklist from checkvist List json", %{checklist: checklist} do
    assert(checklist.id == 774_394)
    assert(checklist.name == "devtest")
    assert(checklist.current_path == [])
    assert(is_list(checklist.tasks))

    nested_task = checklist[1][0]

    assert(is_struct(nested_task))
    assert(nested_task.title == "task2.1")
  end

  test "move task (at checklist top level)", %{checklist: checklist} do
    checklist_updated = Checklist.move(checklist, [0], [1])

    assert(Enum.count(checklist.tasks) == Enum.count(checklist_updated.tasks))
    assert(checklist_updated[0].id == checklist[1].id)
    assert(checklist_updated[1].id == checklist[0].id)
  end

  test "move task (withiin same nested task's children)", %{checklist: checklist} do
    checklist_updated = Checklist.move(checklist, [1, 0], [1, 1])

    assert(checklist_updated != checklist)
    assert(Enum.count(checklist.tasks) == Enum.count(checklist_updated.tasks))
    assert(checklist_updated[1][0].id == checklist[1][1].id)
    assert(checklist_updated[1][0].id == checklist[1][1].id)
  end

  test "move task (between nested tasks' children)", %{checklist: checklist} do
    checklist_updated = Checklist.move(checklist, [1, 0], [0, 0])

    assert(checklist_updated != checklist)
    assert(Enum.count(checklist.tasks) == Enum.count(checklist_updated.tasks))
    assert(length(checklist_updated[0].children) == 1)
    assert(length(checklist_updated[1].children) == 1)
    assert(checklist_updated[0][0] == checklist[1][0])
  end

  test "zooming to task adds correct path to checklist", %{checklist: checklist} do
    zoomed_checklist = Checklist.zoom_to_task(checklist, 53_838_435)
    assert(zoomed_checklist.current_path == [1])
  end

  test "zooming to nonexistent task doesn't change checklist", %{checklist: checklist} do
    # give checklist a current_path to check we're not just assuming []
    checklist = %{checklist | current_path: [1]}
    zoomed_checklist = Checklist.zoom_to_task(checklist, 1)
    assert(zoomed_checklist == checklist)
  end

  test "zooming twice adds correct path to checklist", %{checklist: checklist} do
    zoomed_checklist =
      checklist
      |> Checklist.zoom_to_task(53_838_435)
      |> Checklist.zoom_to_task(53_838_434)

    assert(zoomed_checklist.current_path == [1, 0])
  end

  test "zooming multiple levels at once adds correct path to checklist", %{checklist: checklist} do
    zoomed_checklist = checklist |> Checklist.zoom_to_task(53_838_434)
    assert(zoomed_checklist.current_path == [1, 0])
  end

  test "one level zoom generates correct board", %{checklist: checklist} do
    zoomed_checklist = Checklist.zoom_to_task(checklist, 53_838_435)
    board = Checklist.board(zoomed_checklist)

    assert(Enum.count(board.columns) == 2)
    assert(board.name == "/devtest/task2")
  end

  test "two level zoom generates correct board", %{checklist: checklist} do
    zoomed_checklist =
      checklist
      |> Checklist.zoom_to_task(53_894_527)
      |> Checklist.zoom_to_task(54_455_641)

    board = Checklist.board(zoomed_checklist)

    assert(Enum.count(board.columns) == 1)
    assert(board.name == "/devtest/task3/task3.2")
  end
end
