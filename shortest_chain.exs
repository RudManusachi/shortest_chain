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

  find_path(graph, :a, :e) # => [:a, :b, :e]
  """
  def find_path(graph, a, b), do: find_path(graph, a, b, [a])

  def find_path(graph, a, b, path) do
    new_friends = Map.get(graph, a) -- path

    cond do
      b in new_friends ->
        Enum.reverse([b | path])

      [] == new_friends ->
        []

      true ->
        new_friends
        |> Enum.map(fn friend -> find_path(graph, friend, b, [friend | path]) end)
        |> Enum.reduce(fn
          shortest, [] -> shortest
          shortest, path when length(shortest) < length(path) -> shortest
          _, path -> path
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
    assert ShortestChain.find_path(@graph, :a, :b) == [:a, :b]
  end

  test "friend of friend" do
    assert ShortestChain.find_path(@graph, :a, :i) == [:a, :b, :e, :f, :i]
    assert ShortestChain.find_path(@graph, :a, :g) == [:a, :h, :g]
  end
end
