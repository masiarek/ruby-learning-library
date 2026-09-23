# Exercise 1: a pair-of-equals test with [a, ^a], a band check that pins a
# variable and an expression, and the shadowing trap of a bare name.

def same_pair?(pair) = (pair in [a, ^a])

def band(n, limit)
  case n
  in ^limit then "exactly the limit"
  in ^(limit * 2) then "exactly double"
  in Integer if n < limit then "below"
  else "above"
  end
end

[[3, 3], [3, 4], ["x", "x"]].each do |pair|
  puts format("same_pair?(%-10s) -> %s", pair.inspect, same_pair?(pair))
end

[10, 20, 4, 15].each do |n|
  puts format("band(%2d, 10) -> %s", n, band(n, 10))
end

limit = 10
case 9
in limit then nil
end
puts "after `case 9; in limit`, limit is #{limit} -- the bare name rebound it"
