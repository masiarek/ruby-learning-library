# Kata: one table, four columns -- equal?, ==, eql? and === -- for eight pairs.
# Read it row by row: only equal? cares about identity, only eql? cares about
# the type, and only === treats the left side as a pattern.

pairs = [
  [1, 1], [1, 1.0], ["a", "a"], [:a, :a], [[1], [1]],
  [Integer, 1], [1..3, 2], [/a/, "cat"]
]

puts "   a         b         equal?   ==       eql?     ==="
pairs.each do |a, b|
  cells = [a.equal?(b), a == b, a.eql?(b), a === b].map { |v| v.to_s.ljust(8) }
  puts "   #{a.inspect.ljust(9)} #{b.inspect.ljust(9)} #{cells.join(' ')}".rstrip
end
