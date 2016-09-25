defmodule Parallel do
  def pmap(collection, fun) do
    me = self
    collection
    |> Enum.map(fn (elem) ->
         spawn_link fn -> (send me, {self, fun.(elem)}) end
       end)
    |> Enum.map(fn (pid) ->
         receive do {_pid, result} -> result end
       end)
  end
end

Parallel.pmap 1..100, &IO.puts/1
