# Exercise 1: a method whose whole body is one `case` expression, an `if`
# with no `else` whose condition fails, and the value a loop leaves behind.

def describe(n)
  case
  when n < 0 then "negative"
  when n == 0 then "zero"
  else "positive"
  end
end

[-3, 0, 7].each do |n|
  puts format("describe(%2d) -> %s", n, describe(n))
end

verdict = if 1 > 2 then "impossible" end
puts "if with no else, condition false -> #{verdict.inspect}"

count = 0
left_over = while count < 3
  count += 1
end
puts "while loop, run #{count} times, evaluates to #{left_over.inspect}"

found = [4, 9, 16].each do |n|
  break n if n > 5
end
puts "each with break n -> #{found.inspect}"
