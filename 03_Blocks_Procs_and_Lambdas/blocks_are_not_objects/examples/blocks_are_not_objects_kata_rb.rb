# Exercise 1: repeat(n) yields 0...n and returns the block's values;
# without a block it raises an ArgumentError that names the problem,
# instead of the LocalJumpError a bare yield would raise.

def repeat(n)
  raise ArgumentError, "repeat(#{n}) needs a block" unless block_given?
  (0...n).map { |i| yield i }
end

p repeat(4) { |i| i * i }

begin
  repeat(4)
rescue ArgumentError => e
  puts "#{e.class}: #{e.message}"
end

# The same call written with do...end: the block still belongs to repeat,
# because there is no other method call on the line for it to bind to.
values = repeat(3) do |i|
  i + 10
end
p values
