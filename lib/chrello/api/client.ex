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
  use HTTPoison.Base
  alias Chrello.Model.Board
  alias Chrello.Model.Column
  alias Chrello.Model.Card
  alias Chrello.Util.MapUtil

  @request_headers_base [{"Content-Type", "application/json"}]

  @impl HTTPoison.Base
  def process_url(url) do
    helper = Application.get_env(:chrello, :checkvist_endpoint_helper)
    helper.get() <> url
  end

  @impl HTTPoison.Base
  def process_request_body(body) do
    Jason.encode!(body)
  end

  @impl HTTPoison.Base
  def process_request_headers(extra_headers) do
    extra_headers ++ @request_headers_base
  end

  @impl HTTPoison.Base
  def process_response_body(body) do
    body
    |> Jason.decode!()
  end

  # TODO: replace all raises with error tuples?

  @spec get_board(integer, String.t()) :: Chrello.Model.Board.t()
  def get_board(board_id, api_token) when is_integer(board_id) do
    response =
      get!(
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
      request!(
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
      get!(
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
      request!(
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
    list_tasks = get!("/checklists/#{list_id}/tasks.json", [client_token_header(api_token)]).body

    list_tasks
    |> Enum.filter(fn t -> t["parent_id"] == 0 end)
    |> Enum.map(&MapUtil.rename_keys(&1, %{"content" => "name"}))
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

  # TODO: change to use cards natively? who/where should do the
  # json <-> card conversion? Is there any reason to do it anywhere other than here?
  # def move_card(list_id, card, position) do
  #   body = %{"id" => card., "parent_id" =>
  #   response = put()
  # end
end
