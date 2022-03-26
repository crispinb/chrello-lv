defmodule ChrelloWeb.BoardLive do
  @moduledoc false
  use ChrelloWeb, :live_view
  require Logger
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
    # TODO:
    # OK the user was in the conn, why isn't it appearing in teh socket?
    # or have I misunderstood?
    # I think I have
    # I think we might have to get it from teh session, not the assigns.
    # get_user plug does it for the initial call.
    # But I thought for the initial disconnected moutnwe got the
    # conn assigns in our first socket??
    IO.puts("MOUNT -_----------------->")
    IO.inspect(socket.assigns, label: :CURRENT_SOCKET_ASSIGNS)

    {:ok, assign(socket, :board, nil)}
  end

  def handle_params(%{"board_id" => id}, _uri, %{assigns: %{live_action: :show}} = socket) do

    # can't expunge hard coded until we get the user in teh socket
    tOKEN_MUST_GET_FROM_CURRENT_USER = "nhBJnlw5cZoU3VATWQEVQPXGUzYVAJ"

    socket = assign(socket, :board, get_board(String.to_integer(id), tOKEN_MUST_GET_FROM_CURRENT_USER))
    {:noreply, socket}
  end

  defp get_board(id, token) do
    case Chrello.Api.Client.get_board(id, token) do
      {:ok, board} ->
        board
        |> IO.inspect(label: :RETURNED_BOARD)

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
