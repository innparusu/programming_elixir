defmodule Sequence.Stash do
  use GenServer

  @vsn "1"

  def start_link(current_number) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, {current_number, 1})
  end

  def get_value(pid) do
    GenServer.call pid, :get_value
  end

  def save_value(pid, value) do
    GenServer.cast pid, {:save_value, value}
  end

  def handle_call(:get_value, _from, {current_value, delta}) do
    { :reply, {current_value, delta}, {current_value, delta}}
  end

  def handle_cast({:save_value, value}, _current_value) do
    { :noreply, value }
  end

  def code_change("1", old_state = current_number, _extra) do
    new_state = { current_number, 1 }
    { :ok, new_state }
  end
end
