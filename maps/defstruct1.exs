defmodule Attendee do
  defstruct name: "", paid: false, over_18: true

  def may_attend_affter_party(attendee = %Attendee{}) do
    attendee.paid && attendee.over_18
  end

  def print_vip_badge(%Attendee{name: name}) when name != "" do
    IO.puts "Very cheap badge for #{name}"
  end

  def print_vip_badge(%Attendee{}) do
    raise "missing naem for badge"
  end
end
