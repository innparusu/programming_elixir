# span と リスト内包表記で, 2からnまでの素数のリストを作ろう
defmodule MyList do
  def span(from, to) when from > to, do: []
  def span(from, to), do: [from | span(from+1, to)]

  def prime_list(n) do
    for num <- span(2, n), is_prime?(num), do: num
  end

  def is_prime?(2), do: true
  def is_prime?(x), do: Enum.all?(span(2, x-1), &(rem(x, &1) != 0))
end
