# from から to までの数のリストを返す関数span(from, to)
defmodule MyList do
  def span(from, to) when from > to, do: []
  def span(from, to), do: [from | span(from+1, to)]
end
