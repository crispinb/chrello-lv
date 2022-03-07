defmodule Chrello.Util.MapUtil do
  @moduledoc false

  @spec rename_keys(map(), map()) :: map()
  def rename_keys(map, keypairs) do
    Map.new(map, fn {k, v} = entry ->
      case keypairs[k] do
        nil -> entry
        new_k -> {new_k, v}
      end
    end)
  end

  @spec unflatten(list(), list(integer()), any(), any(), any()) :: list(map())
  @doc """
  Converts a flat list of maps to a tree of lists of maps

  Maps are identified by 'id_key', and child maps by a list of
  these ids keyed by 'children_key'

  Top-level maps from which to start the walk are indicated by 'parent_ids'

  The result is the same list of maps, each with a new 'children_key',
  pointing to a list of embedded child maps.

  Child maps are removed from the parent level in the returned list (they
  are moved further down the tree)
  """
  def unflatten(list, parent_ids, id_key, child_ids_key, children_key) do
    lookup = index_list_of_maps_by_key(list, id_key)
    parents = Enum.filter(list, fn m -> m[id_key] in parent_ids end)
    unflatten(parents, lookup, child_ids_key, children_key)
  end

  defp unflatten(list, %{} = lookup, child_ids_key, children_key) do
    Enum.map(list, fn m ->
      case m[child_ids_key] do
        [] ->
          m

        child_ids ->
          children = Enum.map(child_ids, &Map.get(lookup, &1))
          Map.put(m, children_key, unflatten(children, lookup, child_ids_key, children_key))
      end
    end)
  end

  @spec index_list_of_maps_by_key(list(), any()) :: map()
  @doc """
  Convert list of maps to map keyed by value of k
  """
  def index_list_of_maps_by_key(list, k) do
    list
    |> Enum.map(fn m -> {Map.get(m, k), m} end)
    |> Enum.into(%{})
  end

  @spec index_list_of_maps_by_key_recursive(list(), any(), any()) :: map()
  @doc """
  Convert list of maps to map keyed by value of key,
  recursively for child lists identified by child_key
  """
  def index_list_of_maps_by_key_recursive(list, key, child_key) do
    Enum.map(list, fn m ->
      case m[child_key] do
        l when l in [[], nil] ->
          m

        children ->
          children = index_list_of_maps_by_key_recursive(children, key, child_key)
          Map.put(m, child_key, children)
      end
    end)
    |> index_list_of_maps_by_key(key)
  end
end
