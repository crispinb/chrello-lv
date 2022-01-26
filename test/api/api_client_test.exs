defmodule Chrello.Api.Client.Test do
  use ExUnit.Case, async: true
  import Mox

  setup do
    :verify_on_exit!
    context = Map.merge(TestUtil.load_data(), %{api_token: "token"})

    {:ok, context}
  end

  # Not much here yet, but sets a basis as we add functionality
  test "get board", %{items: items, lists: lists, api_token: token} do
    Chrello.MockApi
    |> expect(:get!, fn "/checklists/1.json", _token -> lists end)
    |> expect(:get!, fn "/checklists/1/tasks.json", _token -> items end)

    board = Chrello.Api.Client.get_board(1, token)

    assert(board.name == "devtest")

    assert(
      length(board.columns) == 4,
      "there are 4 top level Checkvist tasks (ie. Chrello columns)"
    )
  end

  test "tasks at levels below 2nd are ignored", %{items: items, lists: lists, api_token: token} do
    Chrello.MockApi
    |> expect(:get!, fn "/checklists/1.json", [_headers] -> lists end)
    |> expect(:get!, fn "/checklists/1/tasks.json", [_headers] -> items end)

    board = Chrello.Api.Client.get_board(1, token)

    cards =
      board.columns
      |> Enum.flat_map(fn c -> c.cards end)

    assert(length(cards) == 5, "there are 5 2nd level Checkvist tasks (ie. Chrello cards)")
  end

  test "create a user with valid token"

  test "api uses the token we send"

  test "move task within column"

  test "move task between columns"
end
