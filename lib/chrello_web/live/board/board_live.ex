defmodule ChrelloWeb.BoardLive do
  @moduledoc false
  use ChrelloWeb, :live_view
  import ChrelloWeb.BoardComponents

  # TODO: get token from session
  # TODO: ensure we have a logged in user (look at blogsta code for McCord-blessed LiveView means)
  # something like the folllowing
  # Check to see when dis/conneced mounts .get_user_by_session_token gets called
  #   on_mount BlogstaWeb.LiveAuth
  #   def mount(_params, %{"user_token" => user_token}, socket) do
  #     socket = assign_new(socket, :current_user, fn -> Account.get_user_by_session_token(user_token) end)

  #       if !socket.assigns.current_user.confirmed_at do
  #        socket =  redirect(socket, to: "/users/log_in")
  #         {:halt, socket}
  #       else
  #         {:cont, socket}
  #       end
  #   end
  # end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :board, nil)}
  end

  def handle_params(%{"board_id" => id}, _uri, %{assigns: %{live_action: :show}} = socket) do
    socket = assign(socket, :board, get_board(String.to_integer(id)))
    {:noreply, socket}
  end

  defp get_board(id) do
    # case Chrello.Api.Client.get_board(774_394, "wvl6yh5h57eaGw25CbmofwwgGdthKC") do
    case Chrello.Api.Client.get_board(id, "temp: any old crap") do
      {:ok, board} ->
        board

      # TODO: right approach here?
      _ ->
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
