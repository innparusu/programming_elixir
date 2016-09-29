# stack を実装したサーバーを作る
# スタックを初期化する呼び出しではスタックの開始時の中身となるリストが渡される

defmodule OTPServers1.StackServer do
  use GenServer

  def handle_call(:pop, _from, [head|tail]) do
    { :reply, head, tail }
  end

  def handle_cast({:push, element}, stack) do
    { :noreply, [element|stack] }
  end
end
