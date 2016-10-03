defmodule Sequence do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, initial_number) do
    Sequence.Supervisor.start_link(initial_number)
  end
end
