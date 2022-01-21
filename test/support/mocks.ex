# compile mocks so don't get complaints about missing
# methods where mocks are used
# see https://hexdocs.pm/mox/Mox.html#module-compile-time-requirements

Mox.defmock(Chrello.MockApi, for: HTTPoison.Base)
