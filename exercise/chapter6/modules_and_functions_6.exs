defmodule Chop do
  def guess(ans, a..b),  do: guess(ans, div(a+b, 2), a..b)

  def guess(ans, guess_v, _) when ans == guess_v do
    IO.puts "IS it #{guess_v}"
    guess_v
  end

  def guess(ans, guess_v, _..b) when guess_v < ans do
    IO.puts "IS it #{guess_v}"
    guess(ans, div(guess_v+1+b, 2), guess_v+1 .. b)
  end

  def guess(ans, guess_v, a.._) when guess_v > ans do
    IO.puts "IS it #{guess_v}"
    guess(ans, div(a+guess_v-1, 2), a .. guess_v-1)
  end
end
