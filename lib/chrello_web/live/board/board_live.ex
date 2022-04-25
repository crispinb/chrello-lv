defmodule ChrelloWeb.BoardLive do
  @moduledoc false
  use ChrelloWeb, :live_view
  alias Chrello.Model.Checklist
  require Logger

  on_mount ChrelloWeb.Auth.GetUserLive

  def mount(_params, %{"checkvist_auth_token" => token}, socket) do
    socket =
      assign_new(
        socket,
        :current_user,
        fn ->
          case Chrello.Api.Client.get_current_user(token) do
            {:ok, user} -> user
            _error -> nil
          end
        end
      )

    {:ok, assign(socket, :board, nil)}
  end

  def mount(_params, _session, socket) do
    Logger.error("No token in session. Halting")
    {:halt, socket}
  end

  def handle_params(%{"board_id" => id}, _uri, socket) do
    {:noreply, assign_checklist(socket, String.to_integer(id))}
  end

  defp assign_checklist(socket, %Checklist{} = checklist) do
    socket
    |> assign(:checklist, checklist)
    |> assign(:board, Checklist.board(checklist))
  end

  defp assign_checklist(%{assigns: %{current_user: user}} = socket, checklist_id) do
    checklist = get_checklist(checklist_id, user.api_token)
    assign_checklist(socket, checklist)
  end

  defp get_checklist(id, token) do
    Logger.info("Fetching board from Checkvist")

    case Chrello.Api.Client.get_checklist(id, token) do
      {:ok, checklist} ->
        checklist

      # TODO: implement error UI
      {_error, _content} ->
        # error_content: content)
        Logger.error(message: "no board returned")
        nil
    end
  end

  def handle_event("card-dropped", %{"from" => from_path, "to" => to_path}, socket) do
    updated_checklist = Checklist.move(socket.assigns.checklist, from_path, to_path)
    {:noreply, assign_checklist(socket, updated_checklist)}
  end
end
