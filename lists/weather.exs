# 27版だけの特定の観測所の結果だけレポートする
defmodule WeatherHistory do
  def for_location_27([]), do: []
  def for_location_27([ [time, 27, temp, rain] | tail]) do
    [ [time, 27, temp, rain] | for_location_27(tail) ]
  end
  def for_location_27([_ | tail]), do: for_location_27(tail)
end
