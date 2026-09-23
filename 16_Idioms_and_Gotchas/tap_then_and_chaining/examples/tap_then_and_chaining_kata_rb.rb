# Kata: a three-step chain with a `tap` after each step, so every intermediate
# collection is printed and the chain still returns its final value.

words = %w[pear fig banana kiwi apple plum]

result = words
  .select { |w| w.length > 3 }
  .tap { |ws| puts "after select: #{ws.inspect}" }
  .map(&:upcase)
  .tap { |ws| puts "after map:    #{ws.inspect}" }
  .sort
  .tap { |ws| puts "after sort:   #{ws.inspect}" }

puts "returned:     #{result.inspect}"
puts "same object as the last tap saw? #{result.equal?(result.tap { |r| r })}"
