defmodule MyLink do
  def replay(pid) do
    send pid, "replay"
    exit(:boom)
  end

  def run do
    Process.flag(:trap_exit, true)
    spawn_link(MyLink, :replay, [self])
    :timer.sleep(500)
    receive do
      msg ->
        IO.puts "MESSAGE RECEIVED: #{inspect msg}"
      after 500 ->
        IO.puts "TIME OUT"
    end
    receive do
      msg ->
        IO.puts "MESSAGE RECEIVED: #{inspect msg}"
      after 500 ->
        IO.puts "TIME OUT"
    end
  end
end


MyLink.run
