defmodule Chrello.User do
  defstruct api_token: nil, email: nil, checkvist_id: nil, username: nil

  @type t :: %__MODULE__{
          api_token: String.t(),
          email: String.t(),
          username: String.t(),
          checkvist_id: integer()
        }

  def new(%{"id" => id, "email" => email, "username" => username}) do
    %__MODULE__{checkvist_id: id, email: email, username: username}
  end
end
