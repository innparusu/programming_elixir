# 任意の引数を取る ok! という関数を書く
#   - パラメータが{:ok, data} というtupleであれば, data を返す
#   - そうでなければパラメータ情報を含む例外を発生させる

defmodule Ok do
  def ok!({:ok, data}), do: data
  def ok!({_, message}), do: raise "#{message}"
end
