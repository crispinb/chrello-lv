defmodule ChrelloWeb.BoardLive do
  use ChrelloWeb, :live_view
  import ChrelloWeb.BoardComponents
  alias Chrello.Card
  alias Chrello.Column

  # colums - name, list of cards
  # card - title,

  # does unique column_id here make a case for ecto schema? (with or without backend)
  def mount(_params, _session, socket) do
    socket = assign_new(socket, :columns, &get_columns/0)

    {:ok, socket}
  end

  # TODO: replace with context / data layer fn
  defp get_columns do
    [
      %Column{
        id: "column-1",
        title: "column 1",
        cards: [
          %Card{id: "card-1", title: "card 1", body: "some text on card 1"},
          %Card{id: "card-2", title: "card 2", body: "some text on card 2"}
        ]
      },
      %Column{
        id: "column-2",
        title: "column 2",
        cards: [
          %Card{id: "card-3", title: "card 3", body: "some text on card 3"},
          %Card{id: "card-4", title: "card 4", body: "some text on card 4"}
        ]
      },
      %Column{
        id: "column-3",
        title: "column 3",
        cards: [
          %Card{id: "card-5", title: "card 5", body: "some text on card 5"},
          %Card{id: "card-6", title: "card 6", body: "some text on card 6"}
        ]
      }
    ]
  end

  # {card_id: from: to:}
  # from/to: {col: , index:}
  def handle_event("card-dropped", payload, socket) do
    IO.inspect(payload, label: :received_drag_event)
    socket = assign(socket, columns: card_dropped(socket.assigns.columns, payload))

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
    IO.puts("Drag event from [#{from_col}, #{from_index}], to #{to_col}, #{to_index}")
    columns
  end

  # TODO: this doesn't work - our col calc is right, but the dest column
  # isn't updated in LiveView. WHY WHY WHY
  # TODO: also we need to decide if we're using indices or element ids
  def move_card(
        columns,
        %{
          "from" => {from_col_index, from_card_index},
          "to" => {to_col_index, to_card_index}
        }
      ) do
    # TODO: replace all this crud with Access if possible
    #   # or some other way? This is ugly and really fucking hard to debug
    IO.inspect(columns, label: :cols_in)

    {from_col, _} = List.pop_at(columns, from_col_index)
    {to_col, _} = List.pop_at(columns, to_col_index)

    {card, from_col_cards} = List.pop_at(from_col.cards, from_card_index)
    IO.inspect(from_col_cards, label: :from_cards)
    from_col = %Column{from_col | cards: from_col_cards}
    IO.inspect(from_col, label: :from_col)

    to_col_cards = List.insert_at(to_col.cards, to_card_index, card)
    to_col = %{to_col | cards: to_col_cards}

    columns = List.replace_at(columns, from_col_index, from_col)
    columns = List.replace_at(columns, to_col_index, to_col)
    IO.inspect(columns, label: :cols_out)

    columns
  end
end
