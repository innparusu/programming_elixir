defmodule MyEnum do
  def all?([], _), do: true
  def all?([head|tail], func), do: func.(head) && all?(tail, func)
  
  def each([], _), do: :ok
  def each([head|tail], func) do
    func.(head)
    each(tail, func)
  end

  def filter([], _), do: []
  def filter([head|tail], func)  do
    if func.(head) do
      [head|filter(tail, func)]
    else
      filter(tail, func)
    end
  end

  def split(list, count) when count < 0, do: list |> reverse |> _split([], -(count)) |> reverse |> map(&reverse/1) |> to_tuple

  def split(list, count),  do: _split(list, [], count) |> to_tuple

  defp _split([], list, _), do: [list, []]

  defp _split(tail_list, list, count) when count==0, do: [list, tail_list]


  defp _split([head|tail], list, count), do: _split(tail, list++[head], count-1)


  defp reverse([]), do: []

  defp reverse([head|tail]), do: reverse(tail) ++ [head]

  defp map([], _), do: []
  defp map([head|tail], func), do: [func.(head) | map(tail, func)]

  defp to_tuple([a,b]), do: {a,b}

  def take([], _), do: []
  def take(_, count) when count == 0, do: []
  def take(list, count) when count < 0 , do: list |> reverse |> take(-(count)) |> reverse
  def take([head|tail], count), do: [head|take(tail, count-1)]

  def flatten([]), do: []
  def flatten([head|tail]) when is_list(head), do: flatten(head) ++ flatten(tail)
  def flatten([head|tail]), do: [head] ++ flatten(tail)
end
