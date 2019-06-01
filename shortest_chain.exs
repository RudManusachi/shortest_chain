defmodule ShortestChain do
  @doc ~S"""
  suppose our graph is represented as a Map with "users" as a keys and their friends as a list in value

        _____:a_______
       /      \   \   \
      :h  :e--:b--:c  :d
       |  |     \_____/
      :g--:f--:i

  ## Examples

      iex> graph = %{
      ...> :a => [:b, :c, :d, :h],
      ...> :b => [:a, :c, :d, :e],
      ...> :c => [:a, :b],
      ...> :d => [:a, :b],
      ...> :e => [:b, :f],
      ...> :f => [:e, :g, :i],
      ...> :g => [:f, :h],
      ...> :h => [:a, :g],
      ...> :i => [:f]
      ...> }
      iex>
      iex> ShortestChain.find_min_path(graph, :a, :e)
      [:a, :b, :e]
  """
  def find_min_path(graph, a, b), do: find_min_path(graph, a, b, [a])

  def find_min_path(graph, a, b, path) do
    # get the list of friends of `a` and leave only ones that are not in `path` yet (avoid cycling)
    new_friends =
      graph
      |> Map.get(a)
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(path))

    cond do
      # base case
      b in new_friends ->
        Enum.reverse([b | path])

      MapSet.size(new_friends) == 0 ->
        :no_path

      true ->
        new_friends
        |> Task.async_stream(&find_min_path(graph, &1, b, [&1 | path]), ordered: false)
        |> Stream.map(fn {:ok, path} -> path end)
        |> Enum.reduce(fn
          shortest_path, :no_path -> shortest_path
          shortest_path, path when length(shortest_path) < length(path) -> shortest_path
          _shortest_path, path -> path
        end)
    end
  end
end
