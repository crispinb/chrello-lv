defmodule ChrelloWeb.LoginController do
  use ChrelloWeb, :controller

  def index(conn, _params) do
    render(conn, "login.html")
  end

  def login(conn, _params) do
    IO.puts("faking login ...")

    conn =
      conn
      # TODO: check that this works
      # (ie. that the auth token is used to get a client token)
      |> put_session(:checkvist_auth_token, "nhBJnlw5cZoU3VATWQEVQPXGUzYVAJ")

      IO.puts("Auth token in plugin: #{Plug.Conn.get_session(conn, :checkvist_auth_token)}")

    # TODO: go to initial conn request location
    redirect(conn, to: "/board/774394")
  end
end
