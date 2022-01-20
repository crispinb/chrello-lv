defmodule Chrello.CheckvistApiClient do
  alias Chrello.CheckvistApi, as: API

  def get_list!(list_id) when is_integer(list_id) do
    API.get!("/#{list_id}/tasks.json").body
  end

  # ?
  # def get_list(list_name) when is_string(list_name) do
  #   :unimplemented
  # end
end
