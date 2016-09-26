defmodule MyFile do
  def search(scheduler) do
    send scheduler, {:ready, self}
    receive do
      {:fib, file, client} ->
        send client, {:answer, file, search_word_count("hoge", file), self}
        search(scheduler)
        {:shutdown} ->
          exit(:normal)
    end
  end
  
  defp search_word_count(word, file) do
    length(String.split(File.read!(file), word)) - 1
  end
end

defmodule Scheduler do

  def run(num_processes, module, func, to_calculate) do
    (1..num_processes)
    |> Enum.map(fn(_) -> spawn(module, func, [self]) end)
    |> schedule_processes(to_calculate, [])
  end

  defp schedule_processes(processes, queue, results) do
    receive do
      {:ready, pid} when length(queue) > 0 ->
        [next | tail] = queue
        send pid, {:fib, next, self}
        schedule_processes(processes, tail, results)

      {:ready, pid} ->
        send pid, {:shutdown}
        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), queue, results)
        else
          Enum.sort(results, fn {n1, _}, {n2, _} -> n1 <= n2 end)
        end

        {:answer, number, result, _pid} ->
          schedule_processes(processes, queue, [ {number, result} | results ])
    end
  end
end

dir = "./test"
files = File.ls!(dir)
full_path_files = Enum.map(files, fn file -> dir <> "/" <> file end)

Enum.each 1..10, fn num_processes ->
  {time, result} = :timer.tc(
   Scheduler, :run,
   [num_processes, MyFile, :search, full_path_files]
  )

  if num_processes == 1 do
    IO.puts inspect result
    IO.puts "\n # time(s)"
  end
  :io.format "~2B    ~.2f~n", [num_processes, time/1000000.0]
end
