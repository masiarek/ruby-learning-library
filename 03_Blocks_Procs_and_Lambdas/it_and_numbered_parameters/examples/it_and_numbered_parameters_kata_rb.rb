# Exercise 1: five blocks written three ways -- |x|, _1 and it -- agree on
# every input; the pairwise one reads differently with `it`, because `it` is one
# parameter holding the whole pair, while `_1 + _2` are two parameters.

xs = [3, 1, 2]

named   = [xs.map { |x| x * 2 }, xs.select { |x| x.odd? }, xs.sort_by { |x| -x }, xs.sum { |x| x * 10 }]
numbered = [xs.map { _1 * 2 },   xs.select { _1.odd? },   xs.sort_by { -_1 },    xs.sum { _1 * 10 }]
with_it  = [xs.map { it * 2 },   xs.select { it.odd? },   xs.sort_by { -it },    xs.sum { it * 10 }]

puts "named:    #{named}"
puts "numbered: #{numbered}"
puts "it:       #{with_it}"
puts "all three agree: #{named == numbered && numbered == with_it}"

pairs = [[1, 2], [3, 4]]
puts "pairs with |a, b|: #{pairs.map { |a, b| a + b }}, with _1 + _2: #{pairs.map { _1 + _2 }}"
puts "pairs with it, which is the whole pair: #{pairs.map { it.sum }}"
