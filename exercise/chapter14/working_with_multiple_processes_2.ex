defmodule MyProcess do
  def receive_token(pid) do
    receive do
      token -> send pid, token
    end
  end
end

pid1 = spawn(MyProcess, :receive_token, [self])
pid2 = spawn(MyProcess, :receive_token, [self])

send pid1, "fred"
send pid2, "betty"

receive do
  token -> IO.puts token
end

receive do
  token -> IO.puts token
end
