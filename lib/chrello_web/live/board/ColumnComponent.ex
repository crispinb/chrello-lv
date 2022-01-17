defmodule ChrelloWeb.ColumnComponent do
  use Phoenix.LiveComponent

  # sketch out statically first to figure out drag-drop etc
  # then parameterise with numbers of slots, colours, titles, etc

  # <div id="slot1" class="m-4 h-40 bg-blue-50 p-4 border-2 border-black">
  #         test slot
  #       </div>
  #       <div id="slot2" class="m-4 h-40 bg-blue-50 p-4 border-2 border-black">
  #         test slot
  #       </div>
  #       <div id="slot3" class="m-4 h-40 bg-blue-50 p-4 border-2 border-black">
  #         test slot
  #       </div>
  #       <div id="slot4" class="m-4 h-40 bg-blue-50 p-4 border-2 border-black">
  #         test slot
  #       </div>

  def render(assigns) do
    ~H"""
    <div id="column-container" class="">
      <div id="col-header" class="bg-blue-100 text-center">Title</div>
      <div id="column-slots" phx-hook="dragDropHook">

      </div>
    </div>
    """
  end
end
