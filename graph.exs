defmodule Graph do
  def generate(n, max_neighbours) do
    vertices = MapSet.new(0..n)

    incomplete_graph =
      for v <- vertices, into: %{} do
        neighbours =
          vertices
          |> MapSet.delete(v)
          |> Enum.take_random(Enum.random(1..max_neighbours))
          |> MapSet.new()

        {v, neighbours}
      end

    incomplete_graph
    |> Enum.to_list()
    |> Enum.reduce(incomplete_graph, fn {v, neighbours}, graph ->
      Enum.reduce(neighbours, graph, fn n, i_graph ->
        updated_neigbours =
          i_graph
          |> Map.get(n)
          |> MapSet.put(v)

        Map.put(i_graph, n, updated_neigbours)
      end)
    end)
  end
end
