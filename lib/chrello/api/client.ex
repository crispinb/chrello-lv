defmodule Chrello.Api.Client do
  @moduledoc """
  Chrello & Checkvist use different terminology

  |  Chrello | Checkvist| Notes     |
  |  ------- | -------  | -------   |
  | Board    | List     |           |
  | Column   | Task     | Top-level |
  | Card     | Task     | 2nd level |


  Checkvist tasks' "position" property is 1-based. We convert to 0-based internally

  Errors are:
    {:http_error, {status_code, description (string)}}
    {:network_error, reason (string)}

  """
  use HTTPoison.Base
  require Logger
  alias Chrello.Model.Board
  alias Chrello.Model.Card

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
  # TODO: look for better way to handle this
  # We don't have access here to headers so can't determine expected content type
  # If (eg) we get a 404 it probably won't be json, so Jason.decode will fail
  # For now: on failure just log and return unchanged response body
  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        decoded

      {:error, details} ->
        Logger.info("Jason error decoding response body: #{Exception.message(details)}")
        body
    end
  end

  @spec get_board(integer, String.t()) :: {:ok, Chrello.Model.Board.t()} | {:error, any()}
  def get_board(board_id, api_token) when is_integer(board_id) do
    with {:ok, response} when response.status_code == 200 <-
           get("/checklists/#{board_id}.json", [client_token_header(api_token)]),
         {:ok, tasks} <- get_tasks(board_id, api_token) do
      {:ok, Board.new(response.body, tasks)}
    else
      # http or network error
      {_ok_or_error, response_or_error} ->
        error(response_or_error)
    end
  end

  def get_current_user(token) do
    case get("/auth/curr_user.json", [client_token_header(token)]) do
      {:ok, response} when response.status_code == 200 ->
        user = Chrello.User.new(response.body)
        {:ok, user}

      {_ok_or_error, response_or_error} ->
        error(response_or_error)
    end
  end

  # TODO: replace with new  err handling approach
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

  def refresh_auth_token(old_token) do
    case request(:get, "/auth/refresh_token.json?version=2", %{old_token: old_token}) do
      {:ok, response} when response.status_code == 200 -> {:ok, response.body["token"]}
      {_ok_or_error, response_or_error} -> error(response_or_error)
    end
  end

  defp get_tasks(list_id, api_token) when is_integer(list_id) do
    case get("/checklists/#{list_id}/tasks.json", [client_token_header(api_token)]) do
      {:ok, response} -> {:ok, Card.get_cards_from_task_list(response.body)}
      err -> err
    end
  end

  # create a network error
  defp error(%HTTPoison.Error{} = error) do
    {:network_error, Atom.to_string(error.reason)}
  end

  # create an htp error
  defp error(%HTTPoison.Response{} = response) when response.status_code !== 200 do
    # We're getting json back from our callback, so we don't know
    # what we're dealing with (eg. whether it implements String.chars)
    # Usually client will ignore, but we'll return it just in case
    {:http_error, {response.status_code, Jason.encode!(response.body)}}
  end

  defp client_token_header(token) do
    {"X-Client-Token", token}
  end
end
