defmodule OtpSupervisors do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    OtpSupervisors.Supervisor.start_link(Application.get_env(:otp_supervisors, :initial_stack))
  end
end
