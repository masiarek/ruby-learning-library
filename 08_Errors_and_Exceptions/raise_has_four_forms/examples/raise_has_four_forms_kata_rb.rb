# Exercise 1: raise with the two-argument form, rescue and report it, re-raise with a
# bare raise, and show that the outer handler receives the very same object.

def must_be_positive(n)
  raise ArgumentError, "expected a positive number, got #{n.inspect}" unless n.is_a?(Numeric) && n.positive?
  n
end

puts "1. a good value passes through"
puts "   must_be_positive(5) -> #{must_be_positive(5)}"

puts "2. a bad value is reported inside, then re-raised to an outer handler"
begin
  begin
    must_be_positive(-2)
  rescue ArgumentError => inner
    puts "   inner handler: #{inner.class}: #{inner.message}"
    raise
  end
rescue ArgumentError => outer
  puts "   outer handler got the same object: #{outer.equal?(inner)}"
end

puts "3. a non-number is reported with inspect, so a string shows its quotes"
begin
  must_be_positive("7")
rescue ArgumentError => e
  puts "   #{e.message}"
end
