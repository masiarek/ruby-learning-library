# Kata: a method whose body is an if/elsif/else needs no `return`; a method
# that ends in `puts` returns nil, and the fix is to end with the value.
def describe(n)
  if n < 0
    "negative"
  elsif n.zero?
    "zero"
  else
    "positive"
  end
end

def describe_and_print(n)
  puts "   #{n} is #{describe(n)}"
end

def describe_and_print_fixed(n)
  puts "   #{n} is #{describe(n)}"
  describe(n)
end

puts "1. describe(-3)                 -> #{describe(-3).inspect}"
puts "2. describe(0)                  -> #{describe(0).inspect}"
puts "3. describe(7)                  -> #{describe(7).inspect}"
puts "4. describe_and_print(7)        -> prints:"
v = describe_and_print(7)
puts "   and returns #{v.inspect}, because puts returns nil"
puts "5. describe_and_print_fixed(7)  -> prints:"
v = describe_and_print_fixed(7)
puts "   and returns #{v.inspect}, because the value is now the last expression"
