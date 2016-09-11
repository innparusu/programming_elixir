# ダブルクオート文字列のリストを取り, そぞれ別々の行で出力する関数
# 各業の文字列は最も長い文字列の幅にセンタリングする
defmodule MyString do
  def center(str_list), do: str_list |> Enum.map(&String.length/1) |> Enum.max |> _print_list(str_list)

  defp _print_list(_, []), do: :ok

  defp _print_list(len, [head | tail]) do
    str = String.rjust(head, String.length(head) + (div(len - String.length(head), 2)))
    IO.puts str
    _print_list(len, tail)
  end
end
