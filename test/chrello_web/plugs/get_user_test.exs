defmodule ChrelloWeb.Plugs.GetUserTest do
  @moduledoc """
  Tests for  the GetUser plug
  """
  use ChrelloWeb.ConnCase, async: true
  alias ChrelloWeb.Plug.GetUser
  alias Chrello.TestData.Load

  setup %{} do
    bypass = Checkvist.EndpointHelper.bypass_checkvist()

    {:ok, %{bypass: bypass}}
  end

  test "if no auth token, redirect" do
    conn = conn_with_session() |> GetUser.call()

    assert(redirected_to(conn) == "/login")
  end

  test "if auth token, get user and assign to :current_user", %{bypass: bypass} do
    stub_get_user(bypass, "old token", "new token")

    conn = conn_with_session(%{checkvist_auth_token: "new token"}) |> GetUser.call()

    user = conn.assigns.current_user

    assert(is_struct(user, Chrello.User), "should return a user")
    assert(user.email == "myself@crisbennett.com")
  end

  test "if auth token fails & token refresh succeeds, then put new token in session & user in assigns",
       %{bypass: bypass} do
    old_token = "old token"
    new_token = "new token"

    stub_get_user(bypass, old_token, new_token)
    stub_refresh_token(bypass, new_token)

    conn = conn_with_session(%{checkvist_auth_token: old_token}) |> GetUser.call()

    user = conn.assigns.current_user

    assert(get_session(conn, :checkvist_auth_token) == new_token)
    assert(is_struct(user, Chrello.User), "conn assigns should have a user struct")
    assert(user.email == "myself@crisbennett.com")
  end

  test "if auth token fails, and token refresh fails -> redirect to /login", %{bypass: bypass} do
    stub_get_user(bypass, "bad token", "new token")
    stub_refresh_token(bypass, "bad token")

    conn = conn_with_session(%{checkvist_auth_token: "bad token"}) |> GetUser.call()

    assert(redirected_to(conn) == "/login")
  end

  defp conn_with_session(session \\ %{}) do
    Phoenix.ConnTest.build_conn()
    |> init_test_session(session)
    |> fetch_flash()
    |> fetch_session()
  end

  defp stub_get_user(bypass, fail_token, success_token) do
    Bypass.stub(bypass, "GET", "/auth/curr_user.json", fn conn ->
      case Plug.Conn.get_req_header(conn, "x-client-token") do
        [^fail_token] -> Plug.Conn.resp(conn, 401, Load.user_bad_token())
        [^success_token] -> Plug.Conn.resp(conn, 200, Load.user())
      end
    end)
  end

  defp stub_refresh_token(bypass, newToken) do
    Bypass.stub(bypass, "GET", "/auth/refresh_token.json", fn conn ->
      Plug.Conn.resp(conn, 200, ~s({"token": "#{newToken}"}))
    end)
  end
end
