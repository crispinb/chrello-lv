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
  # compile_env only works at compile time, so easier to make sense of with a compile_time constant
  @api_module Application.compile_env(:chrello, :api_module)

  # TODO: replace all raises with error tuples
  @spec get_board(integer, String.t()) :: Chrello.Board.Board.t()
  def get_board(board_id, api_token) when is_integer(board_id) do
    response =
      @api_module.get!(
        "/checklists/#{board_id}.json",
        [client_token_header(api_token)]
      )

    case response.status_code do
      200 ->
        board = Board.new(response.body)
        columns = get_columns!(board_id, api_token)
        %Board{board | columns: columns}

      error_code ->
        raise "#{error_code} error: #{response.body["message"]}"
    end
  end

  defp client_token_header(token) do
    {"X-Client-Token", token}
  end

  def get_auth_token!(username, api_key) do
    response =
      @api_module.request!(
        :get,
        "/auth/login.json?version=2",
        %{
          username: username,
          remote_key: api_key
        }
      )

    case response.status_code do
      200 -> response.body["token"]
      _ -> raise "#{response.status_code} error: #{response.body["message"]}"
    end
  end

  def get_current_user(token) do
    response =
      @api_module.get!(
        "/auth/curr_user.json",
        [client_token_header(token)]
      )

    case response.status_code do
      200 ->
        user = Chrello.User.new(response.body)
        {:ok, user}

      _ ->
        {:error, "#{response.status_code} error: #{response.body["message"]}"}
    end
  end

  def refresh_auth_token(old_token) do
    response =
      @api_module.request!(
        :get,
        "/auth/refresh_token.json?version=2",
        %{
          old_token: old_token
        }
      )

    case response.status_code do
      200 -> {:ok, response.body["token"]}
      _ -> {:error, "#{response.status_code} error: #{response.body["message"]}"}
    end
  end

  defp get_columns!(list_id, api_token) when is_integer(list_id) do
    list_tasks =
      @api_module.get!("/checklists/#{list_id}/tasks.json", [client_token_header(api_token)]).body

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
