# Kata: Python's `//` and `round()` reproduced in Ruby, so the numbers a Ruby
# programmer sees in Python stop being surprising.

def py_floor_div(a, b) = a.div(b)          # Integer#div floors, like Python's //
def py_round(x) = x.round(half: :even)     # Python rounds half to even

puts format("%-10s %-8s %s", "a, b", "a / b", "a // b")
[[7, 2], [-7, 2], [7, -2], [-7, -2]].each do |a, b|
  puts format("%-10s %-8s %s", "#{a}, #{b}", a.fdiv(b), py_floor_div(a, b))
end

puts
puts format("%-6s %-12s %s", "x", "x.round", "py_round(x)")
[0.5, 1.5, 2.5, 3.5, -2.5].each do |x|
  puts format("%-6s %-12s %s", x, x.round, py_round(x))
end
