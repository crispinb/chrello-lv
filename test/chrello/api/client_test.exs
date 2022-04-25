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

    Bypass.stub(bypass, "GET", "/checklists/2.json", fn conn ->
      Plug.Conn.resp(conn, 404, Jason.encode!(%{error: "not found!"}))
    end)

    {:ok, %{api_token: "token", bypass: bypass}}
  end

  test "get checklist", %{api_token: token} do
    {:ok, checklist} = Client.get_checklist(1, token)

    assert(checklist.name == "devtest")
    assert(checklist.id == 774_394)
  end

  test "get checklist, network unavailable", %{api_token: token, bypass: bypass} do
    Bypass.down(bypass)

    {:network_error, reason} = Client.get_checklist(1, token)
    assert(is_bitstring(reason))
  end

  test "get checklist, 404 error", %{api_token: token} do
    {:http_error, {code, _description}} = Client.get_checklist(2, token)
    assert(code == 404)
  end

  # test unhappy path

  # test the card containment

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
