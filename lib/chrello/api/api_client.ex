defmodule Chrello.Api.Client do
  @moduledoc """
  Chrello & Checkvist use different terminology

  |  Chrello | Checkvist| Notes     |
  |  ------- | -------  | -------   |
  | Board    | List     |           |
  | Column   | Task     | Top-level |
  | Card     | Task     | 2nd level |

  3rd level and below Checkvist tasks are currently ignored

  """
  alias Chrello.Board.Board
  alias Chrello.Board.Column
  alias Chrello.Board.Card
  alias Chrello.Util.Map, as: Util

  # indirection so we can swap out a mock in tests
  @api_module Application.get_env(:chrello, :api_module)

  @spec get_board(integer) :: Chrello.Board.Board.t()
  def get_board(board_id) when is_integer(board_id) do
    board =
      @api_module.get!("/#{board_id}.json").body
      |> Board.new()

    columns = get_columns!(board_id)

    %Board{board | columns: columns}
  end

  defp get_columns!(list_id) when is_integer(list_id) do
    list_tasks = @api_module.get!("/#{list_id}/tasks.json").body

    list_tasks
    |> Enum.filter(fn t -> t["parent_id"] == 0 end)
    |> Enum.map(&Util.rename_keys(&1, %{"content" => "name"}))
    |> Enum.map(&Column.new(&1))
    |> Enum.map(fn col ->
      %Column{col | cards: get_child_cards(col, list_tasks)}
    end)
  end

  defp get_child_cards(column, tasks) do
    tasks
    |> Enum.filter(fn t -> t["parent_id"] == column.id end)
    |> Enum.map(&Card.new(&1))
  end
end
