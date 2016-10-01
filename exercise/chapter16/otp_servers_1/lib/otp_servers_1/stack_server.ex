# stack を実装したサーバーを作る
# スタックを初期化する呼び出しではスタックの開始時の中身となるリストが渡される

defmodule OTPServers1.StackServer do
  use GenServer
  def start_link(init_stack), do: GenServer.start_link(__MODULE__, init_stack, name: __MODULE__)

  def pop, do: GenServer.call __MODULE__, :pop

  def push(element), do: GenServer.cast __MODULE__, {:push, element}

  def handle_call(:pop, _from, [head|tail]), do: { :reply, head, tail }

  def handle_cast({:push, element}, stack), do: { :noreply, [element|stack] }

  def terminate(reason, state) do
    IO.puts("reason: #{inspect(reason)}")
    IO.puts("state: #{inspect(state)}")
  end
end
