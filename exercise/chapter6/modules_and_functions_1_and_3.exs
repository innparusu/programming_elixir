# Times モジュールに 引数を3倍するtriple関数を拡張しよう

defmodule Times do
  def double(n), do: n * 2
  def triple(n), do: n * 3
  def quadruple(n), do: double(double(n))
end
