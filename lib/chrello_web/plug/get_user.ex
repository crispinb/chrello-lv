defmodule ChrelloWeb.Plug.GetUser do
  @moduledoc """
  Gets user from Checkvist API if we have an auth token in the session.
  Places user in conn assigns under :current_user key.
  If the token is rejected by Checkvist, attempts token refresh.
  If the token is refreshed, put new token in session
  If we don't have a token, or the token refresh fails, redirects to /login.
  """
  import Plug.Conn
  import Phoenix.Controller
  require Logger
  alias ChrelloWeb.Router.Helpers, as: Routes
  alias Chrello.Api.Client, as: API

  def init(options) do
    options
  end

  def call(conn, _options \\ []) do
    with auth_token when not is_nil(auth_token) <-
           Plug.Conn.get_session(conn, :checkvist_auth_token),
         {:ok, conn, new_token} <-
           assign_current_user(conn, auth_token) do
      if new_token != auth_token,
        do: put_session(conn, :checkvist_auth_token, new_token),
        else: conn
    else
      _ -> redirect_to_login(conn)
    end
  end

  defp assign_current_user(conn, token, refresh_token? \\ false) do
    with {:ok, token} <- maybe_refresh_token(token, refresh_token?),
         {:ok, user} <- get_current_user(token) do
      {:ok, assign(conn, :current_user, user), token}
    else
      {:error, :get_user_failure} -> assign_current_user(conn, token, true)
      error -> error
    end
  end

  defp maybe_refresh_token(token, false) do
    {:ok, token}
  end

  defp maybe_refresh_token(token, true) do
    case API.refresh_auth_token(token) do
      {:ok, _token} = success -> success
      error -> log_api_client_error(error)
    end
  end

  defp get_current_user(token) do
    case API.get_current_user(token) do
      {:ok, _user} = success ->
        success

      error ->
        log_api_client_error(error)
        {:error, :get_user_failure}
    end
  end

  defp log_api_client_error({:http_error, {status_code, msg}}) do
    Logger.info(
      "Checkvist API get current user failed with status code #{status_code}, reason: #{msg}"
    )

    :error
  end

  defp log_api_client_error({:network_error, reason}) do
    Logger.info("Network error while calling Checkvist API: #{reason}")
    :error
  end

  defp redirect_to_login(conn) do
    conn
    |> put_flash(:error, "You must log in to Checkvist")
    |> redirect(to: Routes.login_path(conn, :index))
    |> halt
  end
end
