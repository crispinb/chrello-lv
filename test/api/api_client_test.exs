defmodule Chrello.Api.Client.Test do
  use ExUnit.Case, async: true
  import Mox

  setup do
    :verify_on_exit!

    list_data = %{
      body:
        File.read!("test/data/list.json")
        |> Jason.decode!()
    }

    items_data = %{
      body:
        File.read!("test/data/tasks.json")
        |> Jason.decode!()
    }

    {:ok, list_data: list_data, items_data: items_data}
  end

  # Not much here yet, but sets a basis as we add functionality
  test "get board via api", %{items_data: items, list_data: list} do
    Chrello.MockApi
    |> expect(:get!, fn "/1.json" -> list end)
    |> expect(:get!, fn "/1/tasks.json" -> items end)

    board = Chrello.Api.Client.get_board(1)
    assert(board.name == "devtest")

    assert(
      length(board.columns) == 4,
      "there are 4 top level Checkvist tasks (ie. Chrello columns)"
    )
  end

  test "tasks at levels below 2nd are ignored", %{items_data: items, list_data: list} do
    Chrello.MockApi
    |> expect(:get!, fn "/1.json" -> list end)
    |> expect(:get!, fn "/1/tasks.json" -> items end)

    board = Chrello.Api.Client.get_board(1)

    cards =
      board.columns
      |> Enum.flat_map(fn c -> c.cards end)

    assert(length(cards) == 5, "there are 5 2nd level Checkvist tasks (ie. Chrello cards)")
  end
end
