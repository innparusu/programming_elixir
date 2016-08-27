defmodule MyList do
  def max([]), do: []
  def max([head | tail]), do: _max(tail, head)
  defp _max([], max_value), do: max_value
  defp _max([head | tail], max_value) when head > max_value, do: _max(tail, head)
  defp _max([head | tail], max_value) when head < max_value, do: _max(tail, max_value)
end
