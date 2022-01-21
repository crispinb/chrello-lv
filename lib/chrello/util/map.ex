defmodule Chrello.Util.Map do
  def rename_keys(map, keypairs) do
    Map.new(map, fn {k, v} = entry ->
      case keypairs[k] do
        nil -> entry
        new_k -> {new_k, v}
      end
    end)
  end
end
