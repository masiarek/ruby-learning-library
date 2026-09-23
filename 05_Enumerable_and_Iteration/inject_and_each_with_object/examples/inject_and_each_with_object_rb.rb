# inject folds a collection into one value; each_with_object carries a memo
# through it. Rows are numbered so the Python twin
# (inject_and_each_with_object_py.py) can print the same row beside it.

def row(n, label, value) = puts(format("%2d. %-58s %s", n, label, value.inspect))

nums   = [1, 2, 3, 4]
words  = %w[apple banana cherry]
tenths = [0.1] * 10

puts "inject (also called reduce)"
row 1, "nums.inject(:+)", nums.inject(:+)
row 2, "nums.inject(0) { |acc, x| acc + x }", nums.inject(0) { |acc, x| acc + x }
row 3, "nums.inject(10, :+)  (initial value, then a name)", nums.inject(10, :+)
row 4, "nums.inject(:*)", nums.inject(:*)
row 5, "reduce(:+); instance_method(:reduce) == (:inject)", [nums.reduce(:+), Enumerable.instance_method(:reduce) == Enumerable.instance_method(:inject)]
row 6, "[].inject(:+), [].inject(0, :+), [].sum", [[].inject(:+), [].inject(0, :+), [].sum]
row 7, "[7].inject { |a, b| raise }  (one element: no call)", [7].inject { |a, b| raise "never" }
row 8, "words.inject { |best, w| longer of the two }", words.inject { |best, w| w.size > best.size ? w : best }
row 9, "(1..5).inject(:lcm), [12, 18, 24].inject(:gcd)", [(1..5).inject(:lcm), [12, 18, 24].inject(:gcd)]

puts
puts "sum is not inject(:+): floats are compensated"
row 10, "([0.1] * 10).inject(:+)", tenths.inject(:+)
row 11, "([0.1] * 10).sum", tenths.sum
row 12, "[1e100, 1.0, -1e100].inject(:+), .sum", [[1e100, 1.0, -1e100].inject(:+), [1e100, 1.0, -1e100].sum]
row 13, "[0.1, 0.2, 0.3].inject(:+), .sum", [[0.1, 0.2, 0.3].inject(:+), [0.1, 0.2, 0.3].sum]
row 14, "[1, Rational(1, 3)].sum, [1, 2].sum(0.0)", [[1, Rational(1, 3)].sum, [1, 2].sum(0.0)]

puts
puts "each_with_object: the memo comes back whatever the block returns"
row 15, "words.each_with_object({}) { |w, h| h[w] = w.size }", words.each_with_object({}) { |w, h| h[w] = w.size }
row 16, "words.inject({}) { |h, w| h[w] = w.size; h }  (the ; h)", words.inject({}) { |h, w| h[w] = w.size; h }
begin
  nums.inject({}) { |h, x| h[x] = x * 10 }
rescue NoMethodError => e
  row 17, "nums.inject({}) { |h, x| h[x] = x * 10 } raises", "#{e.class}: #{e.message}"
end
row 18, "inject([]) { |acc, x| acc << x * 10 }  (<< returns acc)", nums.inject([]) { |acc, x| acc << x * 10 }
seen_ewo = seen_inj = nil
[5].each_with_object("memo") { |a, b| seen_ewo = [a, b] }
[5].inject("memo") { |a, b| seen_inj = [a, b] }
row 19, "block args: each_with_object |x, memo|, inject |memo, x|", [seen_ewo, seen_inj]
row 20, "each_with_object([]) { |w, acc| acc << w; :ignored }", words.each_with_object([]) { |w, acc| acc << w; :ignored }
row 21, "each_with_object(\"\") { |w, acc| acc += w }  (+= rebinds)", [words.each_with_object("") { |w, acc| acc += w }, words.each_with_object("") { |w, acc| acc << w }]
row 22, "each_with_object(Hash.new(0)) { |c, h| h[c] += 1 }", "banana".chars.each_with_object(Hash.new(0)) { |c, h| h[c] += 1 }

puts
puts "Three more folds"
row 23, "words.sum(\"\"), words.inject(:+)", [words.sum(""), words.inject(:+)]
row 24, "[[1, 2], [3, 4]].inject(:+), .sum([])", [[[1, 2], [3, 4]].inject(:+), [[1, 2], [3, 4]].sum([])]
row 25, "each_with_index.inject(0) { |acc, (x, i)| acc + x * i }", nums.each_with_index.inject(0) { |acc, (x, i)| acc + x * i }
