defmodule ChrelloWeb.CardComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div id="card1" class="h-full w-20 p-3 bg-yellow-200  border-2 border-blue-50 rounded-xl">
            test card
    </div>

    """
  end
end
