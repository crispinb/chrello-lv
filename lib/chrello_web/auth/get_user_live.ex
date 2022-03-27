defmodule ChrelloWeb.Auth.GetUserLive do
  import Phoenix.LiveView
  require Logger

  def on_mount(_mount_type, _params, %{"checkvist_auth_token" => token}, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        case Chrello.Api.Client.get_current_user(token) do
          {:ok, user} ->
            user

          {:http_error, {code, description}} ->
            Logger.error(~s(Http error getting user. Code: #{code}. Reason: #{description}))
            nil

          {:network_error, reason} ->
            Logger.error(~s(Network error getting user. Reason: #{reason}))
            nil
        end
      end)

    if socket.assigns.current_user != nil do
      {:cont, socket}
    else
      {:halt, socket}
    end
  end
end
