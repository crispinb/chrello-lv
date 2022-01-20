defmodule Chrello.CheckvistApi do
use HTTPoison.Base

@endpoint "https://checkvist.com/checklists"
@item_fields ~w(content id parent_id position)

def process_url(url) do
  @endpoint <> url
end

def process_response_body(body) do
 body
 |> Jason.decode!
 |> Enum.map(fn item -> Map.take(item, @item_fields) end)

end

end
