defmodule Chrello.ModelAssignImplementationTest do
  @moduledoc """
  Tests of Assign behaviour implementations for Task and Checklist
  """
  use ExUnit.Case, async: true

  alias Chrello.Model.{Task, Checklist}

  setup do
    tasks = Chrello.TestData.Load.tasks()
    tasks = Task.get_tasks_from_task_list(Jason.decode!(tasks))
    list = Chrello.TestData.Load.list()
    checklist = Checklist.new(Jason.decode!(list), tasks)
    %{checklist: checklist, tasks: tasks}
  end

  describe "Task" do
    test "get 1 level", %{tasks: tasks} do
      task2 = Enum.at(tasks, 1)
      task2_child1 = task2[0]
      # syntaxes for Access? Kernel.get_in, [], Access methods?
      assert(is_struct(task2_child1, Task))
      assert(task2_child1.content == "task2.1")
    end

    test "Get nested task", %{tasks: tasks} do
      task3 = Enum.at(tasks, 2)
      nested_task = get_in(task3, [2, 0, 0])

      assert(nested_task.content == "task 3.3.1.1")
    end

    test "Get property within nested task", %{tasks: tasks} do
      task3 = Enum.at(tasks, 2)

      assert(get_in(task3, [2, 0, 0, :title]) == "task 3.3.1.1")
    end

    test "Pop tasks", %{tasks: tasks} do
      task2 = Enum.at(tasks, 1)

      assert(task2.title == "task2")
      assert(length(task2.children) == 2)
      {task2_1, rest} = pop_in(task2, [0])
      assert(task2_1.title == "task2.1")
      assert(length(rest) == 1)
    end

    test "Get and update tasks", %{tasks: tasks} do
      task2 = Enum.at(tasks, 1)
      task2_1 = get_in(task2, [0])
      task2_2 = get_in(task2, [1])

      # ie replace 2_2 with 2_1
      {old_value, updated_task} = get_and_update_in(task2, [1], fn task -> {task, task2_1} end)
      assert(old_value == task2_2)
      assert(Enum.at(updated_task.children, 0) == Enum.at(updated_task.children, 1))
    end
  end

  describe "Checklist" do
    test "access 1 level", %{checklist: checklist} do
      task1 = checklist[0]

      assert(is_struct(task1, Task))
      assert(task1.content == "task1")
    end

    test "access nested", %{checklist: checklist} do
      nested_task = get_in(checklist, [2, 2, 0, 0])

      assert(nested_task.content == "task 3.3.1.1")
    end

    test "access property within nested", %{checklist: checklist} do
      assert(get_in(checklist, [2, 2, 0, 0, :content]) == "task 3.3.1.1")
    end

    test "get and update", %{checklist: checklist} do
      task2_2 = get_in(checklist, [1, 1])

      {_original2_2, updated_checklist} =
        get_and_update_in(checklist, [1, 0], fn task -> {task, task2_2} end)

      assert(get_in(updated_checklist, [1, 0]) == get_in(checklist, [1, 1]))
    end
  end
end
