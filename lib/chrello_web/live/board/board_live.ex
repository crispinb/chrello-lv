defmodule ChrelloWeb.BoardLive do
  @moduledoc false
  use ChrelloWeb, :live_view
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

  def mount(_params, session, socket) do
    IO.inspect(session, label: :dying_session)
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
    case Chrello.Api.Client.get_board(id, token) do
      {:ok, board} ->
        board

      # TODO: implement error UI
      {_any_error, content} ->
        Logger.error(message: "no board returned", error_content: content)
        nil
    end
  end

  # {card_id: from: to:}
  # from/to: {col: , index:}
  def handle_event("card-dropped", payload, socket) do
    # socket = assign(socket, board: card_dropped(socket.assigns.board, payload))

    {:noreply, socket}
  end

  # def handle_event("move-card", params, socket) do
  #   socket = assign(socket, columns: move_card(socket.assigns.columns, params))
  #   {:noreply, socket}
  # end

  # defp card_dropped(columns, %{
  #        "from" => %{"col" => from_col, "index" => from_index},
  #        "to" => %{"col" => to_col, "index" => to_index}
  #      }) do

  #   columns
  # end

  # def move_card(
  #       columns,
  #       %{
  #         "from" => {from_col_index, from_card_index},
  #         "to" => {to_col_index, to_card_index}
  #       }
  #     ) do
  #   # TODO: replace all this crud with Access if possible
  #   # but best wait for a basic API / model implementation
  #   # when we'll know more about the shape of the data

  #   # {from_col, _} = List.pop_at(columns, from_col_index)
  #   # {to_col, _} = List.pop_at(columns, to_col_index)

  #   # {card, from_col_cards} = List.pop_at(from_col.cards, from_card_index)
  #   # from_col = %Column{from_col | cards: from_col_cards}

  #   # to_col_cards = List.insert_at(to_col.cards, to_card_index, card)
  #   # to_col = %{to_col | cards: to_col_cards}

  #   # columns = List.replace_at(columns, from_col_index, from_col)
  #   # columns = List.replace_at(columns, to_col_index, to_col)

  #   columns
  # end
end
