defmodule ChrelloWeb.PageController do
  use ChrelloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
