defmodule MyList do
  def ceasar([], _n), do: []
  
  def ceasar([head | tail], n) when head + n <= ?z, do: [head+n | ceasar(tail, n)]
  def ceasar([head | tail], n), do: [head+n-26 | ceasar(tail, n)]
end
