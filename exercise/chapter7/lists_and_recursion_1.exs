defmodule MyList do
  def mapsum(list, func), do: map(list, func) |> sum
  defp map([], _func), do: []
  defp map([head | tail], func), do: [func.(head) | map(tail, func)]
  defp sum([]), do: 0
  defp sum([head | tail]), do: head + sum(tail)
end
