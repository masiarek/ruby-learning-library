# Kata: seven folds, each written with inject or each_with_object and nothing else.
def row(n, label, value) = puts(format("%2d. %-44s %s", n, label, value.inspect))

words = %w[pear fig apple plum kiwi]

row 1, "product of 1..6", (1..6).inject(:*)
row 2, "the longest word", words.inject { |best, w| w.size > best.size ? w : best }
row 3, "word => size, with each_with_object", words.each_with_object({}) { |w, h| h[w] = w.size }
row 4, "running totals of [3, 1, 4, 1, 5]", [3, 1, 4, 1, 5].each_with_object([]) { |x, acc| acc << (acc.last || 0) + x }
row 5, "reverse [1, 2, 3] with inject", [1, 2, 3].inject([]) { |acc, x| [x] + acc }
row 6, "group by first letter, with a default block", words.each_with_object(Hash.new { |h, k| h[k] = [] }) { |w, h| h[w[0]] << w }.to_h
row 7, "[0.1] * 10 by inject, then by sum", [([0.1] * 10).inject(:+), ([0.1] * 10).sum]
