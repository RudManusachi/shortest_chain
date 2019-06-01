defmodule ShortestChain do
  @doc """
  suppose our graph is represented as a Map with "users" as a keys and their friends as a list in value

         _:a______
        /  |  \   \
  :e--:b--:c  :d  :h
   |   \______/    |
   |               |
  :f------:g--------

  graph = %{
    :a => [:b, :c, :d, :h],
    :b => [:a, :c, :d, :e],
    :c => [:a, :b],
    :d => [:a, :b],
    :e => [:b, :f],
    :f => [:e, :g, :i],
    :g => [:f, :h],
    :h => [:a, :g],
    :i => [:f]
  }

  find_min_path(graph, :a, :e) # => [:a, :b, :e]
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
        :no_new_friends

      true ->
        new_friends
        |> Enum.map(fn friend -> find_min_path(graph, friend, b, [friend | path]) end)
        |> Enum.reduce(fn
          shortest_path, :no_new_friends -> shortest_path
          shortest_path, path when length(shortest_path) < length(path) -> shortest_path
          _shortest_path, path -> path
        end)
    end
  end
end

ExUnit.start()

defmodule ShortestChainTest do
  use ExUnit.Case

  @graph %{
    :a => [:b, :c, :d, :h],
    :b => [:a, :c, :d, :e],
    :c => [:a, :b],
    :d => [:a, :b],
    :e => [:b, :f],
    :f => [:e, :g, :i],
    :g => [:f, :h],
    :h => [:a, :g],
    :i => [:f]
  }

  test "simple case" do
    assert ShortestChain.find_min_path(@graph, :a, :b) == [:a, :b]
  end

  test "friend of friend" do
    assert ShortestChain.find_min_path(@graph, :a, :i) == [:a, :b, :e, :f, :i]
    assert ShortestChain.find_min_path(@graph, :a, :g) == [:a, :h, :g]
  end
end
