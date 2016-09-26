defmodule Chain do
  def counter(next_pid) do
    receive do
      n ->
        send next_pid, n + 1
    end
  end

  def create_processes(n) do
    last = Enum.reduce 1..n, self,
             fn (_, send_to) ->
               spawn(Chain, :counter, [send_to])
             end

    # 0 を最後に作ったプロセスへ送り, カウントを開始
    send last, 0

    receive do
      # guard節で integer を取った場合のみ実行する
      final_answer when is_integer(final_answer) ->
        "Result is #{inspect(final_answer)}"
    end
  end

  def run(n) do
    # tc はモジュールの名前と関数名と引数を渡すと実行時間を計測し, tupleを返す
    IO.puts inspect :timer.tc(Chain, :create_processes, [n])
  end
end
