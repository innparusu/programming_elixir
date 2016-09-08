# パラメータがアナグラム(並べ替えて同じ文字列)だったらtrueを返す関数
defmodule MyListChar do
  def anagram?(word1, word2), do: Enum.sort(word1) == Enum.sort(word2)
end
