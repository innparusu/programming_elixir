# シングルクオート文字列が印字可能なASCII文字(スペース ~ チルダ)だけを含む場合にtrueを返す
defmodule MyListChar do
  def can_print?([]), do: true
  def can_print?(str), do: Enum.all?(str, &(&1 > ?\s and &1 < ?~))
end
