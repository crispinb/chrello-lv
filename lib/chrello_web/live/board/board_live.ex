defmodule ChrelloWeb.BoardLive do
  @moduledoc false
  use ChrelloWeb, :live_view
  import ChrelloWeb.BoardComponents
  alias Chrello.Model.Card

  # colums - name, list of cards
  # card - title,

  # does unique column_id here make a case for ecto schema? (with or without backend)
  def mount(_params, _session, socket) do
    socket = assign_new(socket, :board, &get_board/0)

    {:ok, socket}
  end

  # move to plug? Which puts the auth_token in an httponly cookie, or
  # redirects to a login page
  defp temp_auth_token(socket) do
    if socket.assigns.checkvist_auth_token do
    else
    end
  end

  # TODO: replace with context / data layer fn
  # must return empty list (not nil) if there are no columns
  defp get_board do
    Chrello.Api.Client.get_board(774_394, "6BLQ71p8wTaKXCH8nuaVOjsNzkSWJX")
  end

  # {card_id: from: to:}
  # from/to: {col: , index:}
  def handle_event("card-dropped", payload, socket) do
    socket = assign(socket, board: card_dropped(socket.assigns.board, payload))

    {:noreply, socket}
  end

  def handle_event("move-card", params, socket) do
    socket = assign(socket, columns: move_card(socket.assigns.columns, params))
    {:noreply, socket}
  end

  defp card_dropped(columns, %{
         "from" => %{"col" => from_col, "index" => from_index},
         "to" => %{"col" => to_col, "index" => to_index}
       }) do
    columns
  end

  def move_card(
        columns,
        %{
          "from" => {from_col_index, from_card_index},
          "to" => {to_col_index, to_card_index}
        }
      ) do
    # TODO: replace all this crud with Access if possible
    # but best wait for a basic API / model implementation
    # when we'll know more about the shape of the data

    # {from_col, _} = List.pop_at(columns, from_col_index)
    # {to_col, _} = List.pop_at(columns, to_col_index)

    # {card, from_col_cards} = List.pop_at(from_col.cards, from_card_index)
    # from_col = %Column{from_col | cards: from_col_cards}

    # to_col_cards = List.insert_at(to_col.cards, to_card_index, card)
    # to_col = %{to_col | cards: to_col_cards}

    # columns = List.replace_at(columns, from_col_index, from_col)
    # columns = List.replace_at(columns, to_col_index, to_col)

    columns
  end
end
