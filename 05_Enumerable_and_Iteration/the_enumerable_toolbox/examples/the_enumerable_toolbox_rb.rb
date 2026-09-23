# The Enumerable toolbox, one method per row, on two small collections.
# Rows are numbered so the Python twin (the_enumerable_toolbox_py.py) can
# print the same row beside it.

def row(n, label, value) = puts(format("%2d. %-44s %s", n, label, value.inspect))

words = %w[fig apple kiwi banana plum cherry]
nums  = [3, 1, 4, 1, 5, 9, 2, 6]
steps = [1, 2, 4, 9, 10, 11, 12, 15]

puts "Transform, keep, drop, find"
row 1,  "map(&:upcase)", words.map(&:upcase)
row 2,  "select { size == 4 }, filter is the same method", [words.select { |w| w.size == 4 }, Array.instance_method(:filter) == Array.instance_method(:select)]
row 3,  "reject { |w| w.size == 4 }", words.reject { |w| w.size == 4 }
row 4,  "find { start_with?(\"b\") }, find { ...(\"z\") }", [words.find { |w| w.start_with?("b") }, words.find { |w| w.start_with?("z") }]
row 5,  "partition { |w| w.size < 5 }", words.partition { |w| w.size < 5 }
row 6,  "filter_map { |w| w.upcase if w.size == 4 }", words.filter_map { |w| w.upcase if w.size == 4 }

puts
puts "Group and count"
row 7,  "group_by(&:size)", words.group_by(&:size)
row 8,  "nums.group_by(&:odd?)  (unsorted input)", nums.group_by(&:odd?)
row 9,  "nums.chunk(&:odd?).to_a  (runs, not groups)", nums.chunk(&:odd?).to_a
row 10, "nums.tally", nums.tally
row 11, "nums.count(&:odd?), words.count", [nums.count(&:odd?), words.count]

puts
puts "Windows and slices"
row 12, "nums.each_slice(3).to_a", nums.each_slice(3).to_a
row 13, "nums.each_cons(2).to_a", nums.each_cons(2).to_a
row 14, "steps.chunk_while { |a, b| b == a + 1 }.to_a", steps.chunk_while { |a, b| b == a + 1 }.to_a
row 15, "steps.slice_when { |a, b| b != a + 1 }.to_a", steps.slice_when { |a, b| b != a + 1 }.to_a
row 16, "words.zip(nums)", words.zip(nums)
row 17, "words.flat_map(&:chars).first(5)", words.flat_map(&:chars).first(5)

puts
puts "Numbering"
row 18, 'each_with_index.map { |w, i| "#{i}:#{w}" }', words.each_with_index.map { |w, i| "#{i}:#{w}" }
row 19, 'map.with_index(1) { |w, i| "#{i}. #{w}" }', words.map.with_index(1) { |w, i| "#{i}. #{w}" }

puts
puts "Reduce to one value"
row 20, "nums.sum, nums.sum { |x| x * x }", [nums.sum, nums.sum { |x| x * x }]
row 21, "nums.minmax, words.minmax_by(&:size)", [nums.minmax, words.minmax_by(&:size)]
row 22, "words.min(2), words.max(2)", [words.min(2), words.max(2)]
row 23, "any? { > 8 }, all?(Integer), none?(String)", [nums.any? { |x| x > 8 }, nums.all?(Integer), nums.none?(String)]

puts
puts "Order and slice"
row 24, "sort_by { |w| [w.size, w] }  (array key)", words.sort_by { |w| [w.size, w] }
row 25, "sort_by { |w| [-w.size, w] }", words.sort_by { |w| [-w.size, w] }
row 26, "take_while { < 5 }, drop_while { < 5 }", [nums.take_while { |x| x < 5 }, nums.drop_while { |x| x < 5 }]
row 27, "nums.uniq", nums.uniq
row 28, "words.cycle.first(8)", words.cycle.first(8)

puts
puts "Two Ruby-only spellings"
row 29, "words.to_h { |w| [w, w.size] }", words.to_h { |w| [w, w.size] }
row 30, "grep(/an/), nums.grep(2..5)  (grep uses ===)", [words.grep(/an/), nums.grep(2..5)]
