# Fizz Buzz の例を case を使って書き換えてみよう

defmodule FizzBuzz do
  def upto(n) when n > 0, do: 1..n |> Enum.map(&fizzbuzz/1)

  defp fizzbuzz(n), do: _fizzword({n, rem(n, 3), rem(n, 5)})
  defp _fizzword(judge_list) do
    case judge_list do
      {_, 0, 0} ->
        "FizzBuzz"
      {_, 0, _} ->
        "Fizz"
      {_, _, 0} ->
        "Buzz"
      {n, _, _} ->
        n
    end
  end
end
