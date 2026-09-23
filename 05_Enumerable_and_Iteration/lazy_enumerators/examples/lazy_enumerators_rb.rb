# An Enumerator::Lazy runs its blocks one element at a time, only as far as
# the consumer asks; an ordinary Enumerable runs each stage to the end before
# the next starts. Rows are numbered so the Python twin (lazy_enumerators_py.py)
# can print the same row beside it.

def row(n, label, value) = puts(format("%2d. %-56s %s", n, label, value.inspect))

trace = []
puts "Eager: every map runs, then every select"
r = (1..4).map { |x| trace << "map(#{x})"; x * 10 }.select { |x| trace << "select(#{x})"; x > 10 }
puts "    " + trace.join(" ")
row 1, "(1..4).map { }.select { }", r

trace.clear
puts "Lazy: one element through both blocks, and it stops at the second hit"
r = (1..4).lazy.map { |x| trace << "map(#{x})"; x * 10 }.select { |x| trace << "select(#{x})"; x > 10 }.first(2)
puts "    " + trace.join(" ")
row 2, "(1..4).lazy.map { }.select { }.first(2)", r

puts
puts "An endless source, which only a lazy chain can map over"
row 3, "(1..Float::INFINITY).lazy.map { }.select { }.first(3)", (1..Float::INFINITY).lazy.map { |x| x * 2 }.select { |x| x % 3 == 0 }.first(3)
calls = 0
r = (1..).lazy.map { |x| calls += 1; x * 2 }.select { |x| x % 3 == 0 }.first(3)
row 4, "(1..).lazy, same chain; map calls it took", [r, calls]
row 5, "(1..).lazy.take_while { |x| x < 4 }.to_a", (1..).lazy.take_while { |x| x < 4 }.to_a
row 6, "(1..).lazy.each_slice(2).first(2)", (1..).lazy.each_slice(2).first(2)
row 7, "(1..).lazy.filter_map { x * 2 if x.even? }.first(3)", (1..).lazy.filter_map { |x| x * 2 if x.even? }.first(3)
row 8, "(1..).lazy.with_index.map { |x, i| x * i }.first(3)", (1..).lazy.with_index.map { |x, i| x * i }.first(3)
row 9, "(1..).lazy.zip(\"a\"..\"c\").first(2)", (1..).lazy.zip("a".."c").first(2)
row 10, "(1..).lazy.map { |x| x % 3 }.uniq.first(3)", (1..).lazy.map { |x| x % 3 }.uniq.first(3)
row 11, "(1..).lazy.flat_map { |x| [x, -x] }.first(4)", (1..).lazy.flat_map { |x| [x, -x] }.first(4)
row 12, "(1..).lazy.drop_while { |x| x < 5 }.first(2)", (1..).lazy.drop_while { |x| x < 5 }.first(2)

puts
puts "Which calls stay lazy, and which ones run the chain"
lazy = (1..4).lazy
row 13, "lazy.class, lazy.map { }.class", [lazy.class, lazy.map { |x| x }.class]
row 14, "lazy.take(2).class, lazy.first(2).class", [lazy.take(2).class, lazy.first(2).class]
row 15, "(1..).lazy.map { |x| x * x }.take(3).force", (1..).lazy.map { |x| x * x }.take(3).force
row 16, "lazy.eager.class, lazy.eager.map { }.class", [lazy.eager.class, lazy.eager.map { |x| x }.class]
row 17, "(1..).lazy.include?(5), (1..3).lazy.map { x * 2 }.sum", [(1..).lazy.include?(5), (1..3).lazy.map { |x| x * 2 }.sum]
row 18, "(1..).lazy.size, [1,2,3].lazy.map {}.size, .select {}.size", [(1..).lazy.size, [1, 2, 3].lazy.map { |x| x }.size, [1, 2, 3].lazy.select { |x| x }.size]
e = (1..).lazy.map { |x| x * 2 }
row 19, "e = (1..).lazy.map { x * 2 }; e.next, e.next", [e.next, e.next]
row 20, "Enumerator::Lazy.ancestors.take(3)", Enumerator::Lazy.ancestors.take(3)
