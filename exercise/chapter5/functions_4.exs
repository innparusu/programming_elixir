prefix = fn str1 -> (fn str2 -> "#{str1} #{str2}" end) end

mrs = prefix.("Mrs")
IO.puts(mrs.("Smith"))
IO.puts(prefix.("Elixir").("Rocks"))
