ExUnit.start()

# TODO: not sure where else to put this ?
defmodule TestUtil do
  def load_data() do
    list_data = %{
      status_code: 200,
      body:
        File.read!("test/data/list.json")
        |> Jason.decode!()
    }

    items_data = %{
      status_code: 200,
      body:
        File.read!("test/data/tasks.json")
        |> Jason.decode!()
    }

    user_data = %{
      status_code: 200,
      body:
        File.read!("test/data/user.json")
        |> Jason.decode!()
    }

    %{lists: list_data, items: items_data, user: user_data}
  end
end
