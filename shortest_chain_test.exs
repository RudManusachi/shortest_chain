ExUnit.start()

defmodule ShortestChainTest do
  use ExUnit.Case
  doctest ShortestChain

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

  test "no friends" do
    assert ShortestChain.find_min_path(%{:a => [], :b => []}, :a, :b) == :no_path
  end
end
