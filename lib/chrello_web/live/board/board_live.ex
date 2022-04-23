defmodule ChrelloWeb.BoardLive do
  @moduledoc false
  use ChrelloWeb, :live_view
  alias Chrello.Model.Board
  require Logger

  on_mount ChrelloWeb.Auth.GetUserLive

  def mount(_params, %{"checkvist_auth_token" => token}, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        case Chrello.Api.Client.get_current_user(token) do
          {:ok, user} -> user
          _error -> nil
        end
      end)

    {:ok, assign(socket, :board, nil)}
  end

  def mount(_params, _session, socket) do
    Logger.error("No token in session. Halting")
    {:halt, socket}
  end

  def handle_params(
        %{"board_id" => id},
        _uri,
        %{assigns: %{current_user: user, live_action: :show}} = socket
      ) do
    token = user.api_token
    socket = assign(socket, :board, get_board(String.to_integer(id), token))
    {:noreply, socket}
  end

  defp get_board(id, token) do
    Logger.info("Fetching board from Checkvist")

    case Chrello.Api.Client.get_board(id, token) do
      {:ok, board} ->
        board

      # TODO: implement error UI
      {_error, _content} ->
        # error_content: content)
        Logger.error(message: "no board returned")
        nil
    end
  end

  def handle_event("card-dropped", %{"from" => from_path, "to" => to_path}, socket) do
    updated_board = Board.move(socket.assigns.board, from_path, to_path)

    {:noreply, assign(socket, :board, updated_board)}
  end
end
