defmodule Chrello.Api.ClientTest do
  @moduledoc """
  Tests for Chrello.Api.Client
  """
  use ExUnit.Case, async: true
  alias Chrello.Api.Client

  setup do
    bypass = Checkvist.EndpointHelper.bypass_checkvist()

    Bypass.stub(bypass, "GET", "/checklists/1.json", fn conn ->
      Plug.Conn.resp(conn, 200, Chrello.TestData.Load.list())
    end)

    Bypass.stub(bypass, "GET", "/checklists/1/tasks.json", fn conn ->
      Plug.Conn.resp(conn, 200, Chrello.TestData.Load.tasks())
    end)

    {:ok, %{api_token: "token"}}
  end

  test "get board", %{api_token: token} do
    board = Client.get_board(1, token)

    assert(board.name == "devtest")

    assert(length(board.columns) == 3)
  end

  # test "change card position (same parent)" do

  #   # move task 53838435 from pos 1 to 2
  #   # should this move a card, or a task?
  #   {:ok, card} = Client.move_task(1, 53838435, 2)

  #   assert(card.content == "card1")

  # end

  # test "change card position (same parent, error: nonexistent position)"

  # test "reparent a task"
  # #, %{items: items, lists: lists, api_token: token} do

  #   # {:ok, card} = Client.move_task(1, 53838435, 53838423, token)

  #   # assert(card.)

  # test "reparent to nonexistent task fails"

  # test "api uses the token we send (or just assert in other tests?)"

  # test "move task between columns"

  # test "edit task text"
end
