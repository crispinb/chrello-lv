ExUnit.start()

Mox.defmock(Chrello.Api.TestEndpoint, for: Chrello.Api.Endpoint)
Application.put_env(:chrello, :checkvist_endpoint_helper, Chrello.Api.TestEndpoint)

# see https://github.com/dashbitco/bytepack_archive/blob/main/apps/bytepack/test/support/stripe_helpers.ex
defmodule Checkvist.EndpointHelper do
  def bypass_checkvist do
    bypass = Bypass.open()
    url = "http://localhost:#{bypass.port}"
    Mox.stub(Chrello.Api.TestEndpoint, :get, fn -> url end)
    bypass
  end
end
