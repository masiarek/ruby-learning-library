# Kata: the six roundings of a half — round, round(half: :even),
# round(half: :down), floor, ceil and truncate — on the halves from -2.5 to 2.5.

puts format("%-6s %6s %6s %6s %6s %6s %6s", "x", "round", "even", "down", "floor", "ceil", "trunc")
[-2.5, -1.5, -0.5, 0.5, 1.5, 2.5].each do |x|
  puts format("%-6s %6d %6d %6d %6d %6d %6d",
              x, x.round, x.round(half: :even), x.round(half: :down), x.floor, x.ceil, x.truncate)
end
