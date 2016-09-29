# stack を実装したサーバーを作る
# スタックを初期化する呼び出しではスタックの開始時の中身となるリストが渡される
# pop インターフェースだけ実装
defmodule OTPServers1.StackServer do
  use GenServer

  def handle_call(:pop, _from, [head|tail]) do
    { :reply, head, tail }
  end
end
