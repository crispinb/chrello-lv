defmodule Chrello.TestData.Load do
  @moduledoc false

  def list do
    File.read!("test/test_data/list.json")
  end

  def tasks_flat do
    File.read!("test/test_data/tasks_flat.json")
  end

  def tasks do
    File.read!("test/test_data/tasks.json")
  end

  def user do
    File.read!("test/test_data/user.json")
  end

  def user_bad_token do
    File.read!("test/test_data/user_bad_token.json")
  end
end
