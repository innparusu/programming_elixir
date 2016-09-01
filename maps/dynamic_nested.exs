nested = %{
  buttercup: %{
    actor: %{
      first: "Robin",
      last: "Wright"
    },
    role: "princess"
  },
  westley: %{
    actor: %{
      first: "Carey",
      last: "Ewes" #typo!
    },
    role: "farm boy"
  }
}

IO.inspect get_in(nested, [:buttercup])
#=> %{actor: %{first: "Robin", last: "Wright"}, role: "princess"}

IO.inspect get_in(nested, [:buttercup, :actor])
#=> %{first: "Robin", last: "Wright"}

IO.inspect put_in(nested, [:westley, :actor, :last], "Elwes")
#=> %{buttercup: %{actor: %{first: "Robin", last: "Wright"}, role: "princess"},
#=>  westley: %{actor: %{first: "Carey", last: "Elwes"}, role: "farm boy"}}
