defmodule Chrello.Api.CheckvistEndpoint do
  @moduledoc """
  Implementation of Chrello.Api.Endpoint
  """
  @behaviour Chrello.Api.Endpoint

  @impl Chrello.Api.Endpoint
  def get do
    "https://checkvist.com/"
  end
end
