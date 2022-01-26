defmodule Chrello.GetUserTest do
  @moduledoc """
  Tests for  the GetUser plug
  """
  use ChrelloWeb.ConnCase, async: true
  alias ChrelloWeb.Plug.GetUser
  import Mox

  setup %{} do
    :verify_on_exit!
    context_map = TestUtil.load_data()
    {:ok, context_map}
  end

  test "if no auth token, redirect" do
    conn =
      conn_with_session()
      |> GetUser.call()

    assert(redirected_to(conn) == "/login")
  end

  test "if auth token, get user and assign to :current_user",
       %{user: user} do
    Chrello.MockApi
    |> expect(:get!, fn "/auth/curr_user.json", [{"X-Client-Token", _token}] -> user end)

    conn =
      conn_with_session(%{checkvist_auth_token: "token"})
      |> GetUser.call()

    user = conn.assigns.current_user

    assert(is_struct(user, Chrello.User), "should return a user")
    assert(user.email == "myself@crisbennett.com")
  end

  test "if auth token fails, and token refresh succeeds -> new token in session & user in assigns",
       %{user: user} do
    new_token = "new_token"

    Chrello.MockApi
    |> expect(:get!, fn "/auth/curr_user.json", [{"X-Client-Token", _token}] ->
      %{status_code: 401, body: %{message: "Unauthenticrized"}}
    end)
    |> expect(:request!, fn :get, "/auth/refresh_token.json?version=2", %{old_token: _token} ->
      %{status_code: 200, body: %{"token" => new_token}}
    end)
    |> expect(:get!, fn "/auth/curr_user.json", [{"X-Client-Token", ^new_token}] -> user end)

    conn =
      conn_with_session(%{checkvist_auth_token: "old token"})
      |> GetUser.call()

    user = conn.assigns.current_user
    assert(get_session(conn, :checkvist_auth_token) == new_token)
    assert(is_struct(user, Chrello.User), "conn assigns should have a user struct")
    assert(user.email == "myself@crisbennett.com")
  end

  test "if auth token fails, and token refresh fails -> redirect to /login" do
    Chrello.MockApi
    |> expect(:get!, fn "/auth/curr_user.json", _ ->
      %{status_code: 401, body: %{"message" => "Unauthenticated"}}
    end)
    |> expect(:request!, fn :get,
                            "/auth/refresh_token.json?version=2",
                            %{old_token: "bad token"} ->
      %{status_code: 401, body: %{message: "old_token parameter is not valid"}}
    end)

    conn =
      conn_with_session(%{checkvist_auth_token: "bad token"})
      |> GetUser.call()

    assert(redirected_to(conn) == "/login")
  end

  defp conn_with_session(session \\ %{}) do
    Phoenix.ConnTest.build_conn()
    |> init_test_session(session)
    |> fetch_flash()
    |> fetch_session()
  end
end
