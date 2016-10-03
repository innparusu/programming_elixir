# stack を実装したサーバーを作る
# スタックを初期化する呼び出しではスタックの開始時の中身となるリストが渡される

defmodule OtpSupervisors.StackServer do
  use GenServer
  def start_link(stash_pid), do: {:ok, _pid} = GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)

  def pop, do: GenServer.call __MODULE__, :pop

  def push(element), do: GenServer.cast __MODULE__, {:push, element}

  def init(stash_pid) do
    current_stack = OtpSupervisors.Stash.get_stack stash_pid
    {:ok, {current_stack, stash_pid} }
  end

  def handle_call(:pop, _from, {[head|tail], stash_pid}), do: { :reply, head, {tail, stash_pid} }

  def handle_cast({:push, element}, {stack, stash_pid}), do: { :noreply, {[element|stack], stash_pid} }

  def terminate(_reason, {current_stack, stash_pid}) do
    OtpSupervisors.Stash.save_stack stash_pid, current_stack
  end
end
