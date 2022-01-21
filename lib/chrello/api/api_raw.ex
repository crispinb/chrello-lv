defmodule Chrello.Api.Raw do
  use HTTPoison.Base

  @endpoint "https://checkvist.com/checklists"

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    body
    |> Jason.decode!()
  end
end
