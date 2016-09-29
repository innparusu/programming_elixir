# nodes-4
# クライアントをリングとしてつなげてtick サーバーを再実装しよう
#
defmodule Ticker do

  @interval 2000
  @name :ticker

  def start do
    pid = spawn(__MODULE__, :generator, [[]])
    :global.register_name(@name, pid)
  end

  def register(client_pid) do
    send :global.whereis_name(@name), { :register, client_pid }
  end

  def generator([]) do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        generator([pid])
    end
  end

  def generator(clients) do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        send List.first(clients), { pid, :new_client }
        send pid, { List.last(clients), :new_client }
        generator([pid|clients])
    end
  end
end

defmodule Client do
  @interval 2000

  def start do
    pid = spawn(__MODULE__, :receiver, [])
    Ticker.register(pid)
  end

  def receiver do
    receive do
      { next_client, :new_client } ->
        IO.puts "tock in client"
        _receiver(next_client)
    end
  end

  defp _receiver(next_client) do
    receive do
      { new_next_client, :new_client } ->
        IO.puts "tock in client"
        _receiver(new_next_client)
      { :tick } ->
        IO.puts "tock in client"
        _receiver(next_client)
    after
      @interval ->
        IO.puts "next #{inspect(next_client)}"
        send next_client, { :tick }
        _receiver(next_client)
    end
  end
end
