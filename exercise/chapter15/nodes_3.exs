defmodule Ticker do

  @interval 2000
  @name :ticker

  def start do
    pid = spawn(__MODULE__, :generator, [[], []])
    :global.register_name(@name, pid)
  end

  def register(client_pid) do
    send :global.whereis_name(@name), { :register, client_pid }
  end

  def generator([], []) do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        generator([pid], [pid])
    after
      @interval ->
        IO.puts "tick"
        generator([], [])
    end
  end

  def generator(clients, []) do
    generator(clients, clients)
  end

  def generator(clients, [send_client|rest_clients]) do
    receive do
      { :register, pid } ->
        IO.puts "registering #{inspect pid}"
        generator(clients ++ [pid], [send_client|rest_clients] ++ [pid])
    after
      @interval ->
        IO.puts "tick"
        send send_client, { :tick }
        generator(clients, rest_clients)
    end
  end

end

defmodule Client do
  def start do
    pid = spawn(__MODULE__, :receiver, [])
    Ticker.register(pid)
  end

  def receiver do
    receive do
      { :tick } ->
        IO.puts "tock in client"
        receiver
    end
  end
end
