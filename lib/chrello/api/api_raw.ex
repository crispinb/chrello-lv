defmodule Chrello.Api.Raw do
  use HTTPoison.Base

  @endpoint "https://checkvist.com"
  @request_headers_base [{"Content-Type", "application/json"}]

  @impl HTTPoison.Base
  def process_url(url) do
    @endpoint <> url
  end

  @impl HTTPoison.Base
  def process_request_body(body) do
    Jason.encode!(body)
  end

  def process_request_headers(extra_headers) do
    extra_headers ++ @request_headers_base
  end

  @impl HTTPoison.Base
  def process_response_body(body) do
    body
    |> Jason.decode!()
  end
end
