defmodule ShortestChain do
  def init(initial_value \\ nil) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def update(path) do
    Agent.update(__MODULE__, fn
      stored when is_nil(stored) or length(stored) > length(path) -> path |> IO.inspect()
      stored -> stored |> IO.inspect()
    end)
  end

  @doc ~S"""
  suppose our graph is represented as a Map with "users" as a keys and their friends as a list in value

        _____:a_______
       /      \   \   \
      :h  :e--:b--:c--:d
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
  def find_min_path(graph, a, b) do
    init()
    find_min_path(graph, a, b, [a], [b])
    get()
  end

  def find_min_path(graph, a, b, a_path, b_path) do
    # get the list of friends of `a` and leave only ones that are not in `path` yet (avoid cycling)
    new_friends_a =
      graph
      |> Map.get(a)
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(a_path))

    new_friends_b =
      graph
      |> Map.get(b)
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(b_path))

    intersection = MapSet.intersection(new_friends_a, new_friends_b)

    current_shortest = get()

    cond do
      # base case
      MapSet.size(new_friends_a) == 0 or MapSet.size(new_friends_b) == 0 ->
        :no_path

      MapSet.size(intersection) > 0 ->
        update(Enum.reverse([Enum.random(intersection) | a_path]) ++ b_path)

      is_nil(current_shortest) or
          Enum.count(a_path) + Enum.count(b_path) + 1 < Enum.count(current_shortest) ->
        new_friends_a
        |> Task.async_stream(
          fn n_a ->
            Task.async_stream(
              new_friends_b,
              fn n_b ->
                find_min_path(graph, n_a, n_b, [n_a | a_path], [n_b | b_path])
              end,
              ordered: false,
              timeout: 60_000 * 3
            )
          end,
          ordered: false,
          timeout: 60_000 * 3
        )
        |> Stream.flat_map(fn {:ok, stream} -> Stream.map(stream, fn {:ok, path} -> path end) end)
        |> Enum.reduce(fn
          shortest_path, path when path in [:too_long, :no_path] -> shortest_path
          shortest_path, path when length(shortest_path) < length(path) -> shortest_path
          _shortest_path, path -> path
        end)
        |> update

      true ->
        :too_long
    end
  end
end
