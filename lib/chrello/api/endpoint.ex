defmodule Chrello.Api.Endpoint do
  @moduledoc """
  Behaviour to allow runtime configuration of
  the main Api endpoint
  """
  @callback get() :: String.t()
end
