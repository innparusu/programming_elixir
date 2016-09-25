defmodule MyLink do
  def replay(pid) do
    send pid, "replay"
    raise RuntimeError
  end

  def run do
    spawn_monitor(MyLink, :replay, [self])
    :timer.sleep(500)
    receive do
      msg ->
        IO.puts "MESSAGE RECEIVED: #{inspect msg}"
      after 500 ->
        IO.puts "TIME OUT"
    end
  end
end


MyLink.run
