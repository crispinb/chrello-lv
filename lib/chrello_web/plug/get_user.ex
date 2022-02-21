defmodule ChrelloWeb.Plug.GetUser do
  @moduledoc """
  Gets user as from Checkvist API if we have an auth token
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
    auth_token = Plug.Conn.get_session(conn, :checkvist_auth_token)

    if auth_token do
      case maybe_assign_user(conn, auth_token) do
        :error ->
          case API.refresh_auth_token(auth_token) do
            {:ok, new_token} ->
              conn = put_session(conn, :checkvist_auth_token, new_token)

              case maybe_assign_user(conn, new_token) do
                :error -> redirect_to_login(conn)
                conn -> conn
              end

            error ->
              log_error(error)
          end

        conn ->
          conn
      end
    else
      redirect_to_login(conn)
    end
  end

  defp maybe_assign_user(conn, token) do
    case API.get_current_user(token) do
      {:ok, user} ->
        assign(conn, :current_user, user)

      error ->
        log_error(error)
    end
  end

  defp log_error({:http_error, {status_code, msg}}) do
    Logger.info(
      "Checkvist API get current user failed with status code #{status_code}, reason: #{msg}"
    )

    :error
  end

  defp log_error({:network_error, reason}) do
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
