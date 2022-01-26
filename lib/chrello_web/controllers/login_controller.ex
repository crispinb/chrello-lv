defmodule ChrelloWeb.LoginController do
  use ChrelloWeb, :controller

  def index(conn, _params) do
    render(conn, "login.html")
  end

  def login(conn, _params) do
    conn =
      conn
      # TODO: replace with a login form
      |> put_session(:checkvist_auth_token, "6BLQ71p8wTaKXCH8nuaVOjsNzkSWJX")

    # TODO: change to whereever user was trying to go
    redirect(conn, to: "/board")
  end
end
