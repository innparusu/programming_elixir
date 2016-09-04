defmodule MyList do
  def total_list(orders, tax_rates), do: orders |> Enum.map(&(add_total_to(&1, tax_rates)))
  def add_total_to(order = [id: _, ship_to: ship_to, net_amount: net_amount], tax_rates) do
    tax_rate     = Keyword.get(tax_rates, ship_to, 0)
    tax          = net_amount * tax_rate
    total_amount = net_amount + tax
    Keyword.put(order, :total_amount, total_amount)
  end
end
