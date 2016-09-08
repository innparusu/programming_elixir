defmodule Parse do
  def calculate(str) do
    {number1, tail} = parse_number(str)
    {op, tail}      = parse_op(tail)
    {number2, _} = parse_number(tail)
    op.(number1, number2)
  end

  defp parse_number([?\s | tail]), do: parse_number(tail)
  defp parse_number(str), do: _parse_number({0, str})

  defp _parse_number({value, [digit | tail]}) when digit in ?0..?9 do
    _parse_number({value * 10 + digit - ?0, tail})
  end
  
  defp _parse_number({value, tail}), do: {value, tail}

  defp parse_op([?\s | tail]), do: parse_op(tail)

  defp parse_op([?+ | tail]), do: {&(&1 + &2), tail}
  defp parse_op([?- | tail]), do: {&(&1 - &2), tail}
  defp parse_op([?* | tail]), do: {&(&1 * &2), tail}
  defp parse_op([?/ | tail]), do: {&(&1 / &2), tail}
end
