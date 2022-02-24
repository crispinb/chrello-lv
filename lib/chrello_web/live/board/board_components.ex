defmodule ChrelloWeb.BoardComponents do
  @moduledoc """
  Functional LiveView components for Chrello boards
  """
  use Phoenix.Component

  def card(assigns) do
    ~H"""
    <div id={@id} class="flex-col w-44 h-44 bg-blue-100 text-center">
      <div id="card_title">
        <%= @title %>
      </div>
      <div id="card-body">
        <%= @content %>
      </div>
    </div>
    """
  end
end
